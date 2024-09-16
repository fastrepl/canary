defmodule Canary.Scraper.Item do
  @derive Jason.Encoder
  defstruct [:id, :level, :title, :content]
end

defmodule Canary.Scraper do
  alias Canary.Scraper.Item

  def run(html) do
    with {:ok, doc} <- Floki.parse_document(html),
         [body] <- doc |> Floki.find("body") do
      items =
        process(body)
        |> Enum.reverse()
        |> Enum.reject(&(&1.level == nil || &1.level == 0))
        |> Enum.reject(&(&1.content == nil || &1.content == ""))
        |> Enum.map(&%Item{&1 | content: String.trim(&1.content)})

      {:ok, items}
    else
      error -> {:error, error}
    end
  end

  def run!(html) do
    {:ok, content} = run(html)
    content
  end

  def print!(html) do
    run!(html)
    |> Enum.each(&IO.puts("#{&1.content}\n-----"))
  end

  defp process(_, acc \\ [])
  defp process({"script", _, _}, acc), do: acc
  defp process({"style", _, _}, acc), do: acc
  defp process({"nav", _, _}, acc), do: acc
  defp process({"header", _, _}, acc), do: acc
  defp process({"footer", _, _}, acc), do: acc
  defp process({:comment, _}, acc), do: acc

  defp process({"h" <> level, _, nodes} = node, acc) do
    id =
      node
      |> Floki.attribute("id")
      |> Enum.at(0)

    level = parse_integer(level)

    title =
      nodes
      |> Enum.map(&to_text/1)
      |> Enum.join(" ")
      |> trim_leading_hash()

    content = String.duplicate("#", level) <> " #{title}\n"

    [%Item{id: id, level: level, title: title, content: content} | acc]
  end

  defp process({"a", _, [text]} = node, acc) when is_binary(text) do
    href = node |> Floki.attribute("href") |> Enum.at(0, "#")
    text = to_text(node)

    if String.trim(text) in ["Skip to content"] do
      acc
    else
      acc |> update_first(&%Item{&1 | content: &1.content <> "[#{text}](#{href})"})
    end
  end

  defp process({"div", _, nodes} = node, acc) do
    is_nav =
      classes(node)
      |> Enum.any?(&String.contains?(&1, "VPLocalNav"))

    # code = nodes |> Enum.find(&(elem(&1, 0) == "pre"))

    cond do
      is_nav ->
        acc

      # not is_nil(code) ->
      #   lang =
      #     classes(node)
      #     |> Enum.find("", &String.contains?(&1, "language-"))
      #     |> String.replace("language-", "")

      #   is_diff =
      #     classes(code)
      #     |> Enum.any?(fn c -> String.contains?(c, "diff") end)

      #   lang = if is_diff, do: "#{lang}-diff", else: lang

      #   rendered_code = process(code) |> Enum.at(0) |> Map.get(:content)
      #   content = "\n```#{lang}\n#{rendered_code}\n```\n"

      #   acc |> update_first(&%Item{&1 | content: &1.content <> content})

      true ->
        nodes |> Enum.reduce(acc, &process(&1, &2))
    end
  end

  defp process({"pre", _, [{"code", _, lines}]}, acc) do
    content =
      lines
      |> Enum.map(fn line ->
        cond do
          ["diff", "remove"] |> Enum.all?(&Enum.member?(classes(line), &1)) -> "-#{to_text(line)}"
          ["diff", "add"] |> Enum.all?(&Enum.member?(classes(line), &1)) -> "+#{to_text(line)}"
          true -> to_text(line)
        end
      end)
      |> Enum.join("\n")

    acc |> update_first(&%Item{&1 | content: &1.content <> content})
  end

  defp process({"code", _, [text]}, acc) when is_binary(text) do
    acc |> update_first(&%Item{&1 | content: &1.content <> "`#{text}`"})
  end

  defp process({"li", _, nodes}, acc) do
    text =
      nodes
      |> Enum.flat_map(fn node -> process(node, [%Item{id: nil, level: nil, content: ""}]) end)
      |> Enum.map(& &1.content)
      |> Enum.join()

    acc |> update_first(&%Item{&1 | content: &1.content <> "\n- #{text}"})
  end

  defp process({"tr", _, nodes}, acc) do
    row = nodes |> Enum.map(&to_text/1) |> Enum.join(",")
    acc |> update_first(&%Item{&1 | content: &1.content <> "\n#{row}"})
  end

  defp process({_, _, [text]}, acc) when is_binary(text) do
    acc |> update_first(&%Item{&1 | content: &1.content <> text})
  end

  defp process(text, acc) when is_binary(text) do
    acc |> update_first(&%Item{&1 | content: &1.content <> text})
  end

  defp process({_, _, nodes}, acc) do
    nodes |> Enum.reduce(acc, &process(&1, &2))
  end

  defp classes(node) do
    node
    |> Floki.attribute("class")
    |> Enum.flat_map(&String.split(&1, " "))
    |> Enum.map(&String.trim/1)
  end

  defp to_text(node) when is_binary(node), do: trim(node)
  defp to_text(node), do: Floki.text(node) |> trim()

  defp trim(s) do
    s
    |> String.to_charlist()
    |> Enum.filter(&(&1 in 0..127))
    |> List.to_string()
    |> String.trim()
  end

  defp update_first(list, fun) when length(list) == 0, do: [fun.(%Item{title: "", content: ""})]
  defp update_first(list, fun), do: List.update_at(list, 0, fun)

  defp parse_integer(s) do
    case Integer.parse(s) do
      {n, _} -> n
      _ -> 0
    end
  end

  defp trim_leading_hash(s) do
    s
    |> String.trim_leading("#")
    |> String.trim()
  end
end

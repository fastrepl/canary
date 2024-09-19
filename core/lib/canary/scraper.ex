defmodule Canary.Scraper.Item do
  @derive Jason.Encoder
  defstruct [:id, :level, :title, :content]
end

# Inspired by: https://github.com/agoodway/html2markdown/blob/06e3587/lib/html2markdown.ex#L6-L32
defmodule Canary.Scraper do
  alias Canary.Scraper.Item

  @non_content_tags [
    "aside",
    "audio",
    "base",
    "button",
    "datalist",
    "embed",
    "form",
    "iframe",
    "input",
    "keygen",
    "nav",
    "noscript",
    "object",
    "output",
    "script",
    "select",
    "source",
    "style",
    "svg",
    "template",
    "textarea",
    "track",
    "video"
  ]

  def run(html) do
    html
    |> preprocess()
    |> process()
    |> postprocess()
  end

  defp postprocess(items) do
    items
    |> Enum.reverse()
    |> Enum.reject(&(&1.level == nil || &1.level == 0))
    |> Enum.reject(&(&1.content == nil || &1.content == ""))
    |> Enum.map(&%Item{&1 | content: String.trim(&1.content)})
  end

  defp preprocess(content) do
    content
    |> ensure_html()
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.filter_out(:comment)
    |> remove_non_content_tags()
  end

  defp ensure_html(content) do
    if is_html_document?(content), do: content, else: wrap_fragment(content)
  end

  defp is_html_document?(content) do
    String.contains?(content, "<html") and String.contains?(content, "<body")
  end

  defp wrap_fragment(fragment), do: "<html><body>#{fragment}</body></html>"

  defp remove_non_content_tags(document) do
    Enum.reduce(@non_content_tags, document, &Floki.filter_out(&2, &1))
  end

  defp process(_, acc \\ [])

  defp process(nodes, acc) when is_list(nodes) do
    nodes
    |> Enum.reduce(acc, &process/2)
  end

  defp process({"h" <> level, _, nodes} = node, acc)
       when level in ["1", "2", "3", "4", "5", "6"] do
    level = String.to_integer(level)

    id =
      node
      |> Floki.attribute("id")
      |> Enum.at(0)

    title =
      nodes
      |> Enum.map(&to_text/1)
      |> Enum.join(" ")
      |> String.trim_leading("#")
      |> String.trim()

    content = "#{String.duplicate("#", level)} #{title}" <> "\n"
    [%Item{id: id, level: level, title: title, content: content} | acc]
  end

  defp process({"a", _, [text]} = node, acc) when is_binary(text) do
    href = node |> Floki.attribute("href") |> Enum.at(0, "#")
    text = to_text(node)

    if String.trim(text) in ["Skip to content"] do
      acc
    else
      acc |> append_content("[#{text}](#{href})")
    end
  end

  defp process({"div", _, nodes} = node, acc) do
    is_nav =
      classes(node)
      |> Enum.any?(&String.contains?(&1, "VPLocalNav"))

    cond do
      is_nav ->
        acc

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

    acc |> append_content(content)
  end

  defp process({"code", _, [text]}, acc) when is_binary(text) do
    acc |> append_content("`#{text}`")
  end

  defp process({"li", _, nodes}, acc) do
    text =
      nodes
      |> Enum.flat_map(fn node -> process(node, [%Item{id: nil, level: nil, content: ""}]) end)
      |> Enum.map(& &1.content)
      |> Enum.join()

    acc |> append_content("\n- #{text}")
  end

  defp process({"tr", _, nodes}, acc) do
    row = nodes |> Enum.map(&to_text/1) |> Enum.join(",")
    acc |> append_content("\n#{row}")
  end

  defp process({_, _, [text]}, acc) when is_binary(text) do
    acc |> append_content(text)
  end

  defp process(text, acc) when is_binary(text) do
    acc |> append_content(text)
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

  defp append_content(list, content) when length(list) > 0 do
    list
    |> List.update_at(0, &%Item{&1 | content: &1.content <> content})
  end

  defp append_content(list, _content), do: list
end

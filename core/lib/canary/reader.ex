defmodule Canary.Reader do
  @callback html_to_md(String.t()) :: {:ok, String.t()} | {:error, any()}

  def html_to_md(html), do: impl().html_to_md(html)
  defp impl(), do: Canary.Reader.Default
end

defmodule Canary.Reader.Default do
  @behaviour Canary.Reader

  def html_to_md(html) do
    case Floki.parse_document(html) do
      {:ok, doc} -> {:ok, render(doc)}
      error -> error
    end
  end

  defp render(nodes) when is_list(nodes) do
    nodes
    |> Enum.map(&render/1)
    |> Enum.reject(&(&1 == "" || &1 == "\n"))
    |> Enum.join("\n")
    |> String.trim()
  end

  defp render({tag, _attrs, children}) when tag in ["h1", "h2", "h3", "h4", "h5", "h6"] do
    n = String.to_integer(tag |> String.slice(1..-1//-1))
    "#{String.duplicate("#", n)} #{render(children)}"
  end

  defp render({tag, _attrs, children}) when tag in ["div", "p", "span"] do
    children
    |> Enum.map(&render/1)
    |> Enum.join("\n")
    |> String.trim()
  end

  defp render({"img", attrs, _}) do
    src = attrs |> Enum.find_value(fn {k, v} -> if k == "src", do: v end)
    alt = attrs |> Enum.find_value(fn {k, v} -> if k == "alt", do: v end)
    "![#{alt || ""}](#{src})"
  end

  defp render({"a", attrs, childs}) do
    href = attrs |> Enum.find_value(fn {k, v} -> if k == "href", do: v end)
    "[#{render(childs)}](#{href})"
  end

  defp render({"ol", _, items}) do
    items
    |> Enum.with_index(1)
    |> Enum.map_join("\n", fn {item, index} -> "#{index}. #{render(item)}" end)
  end

  defp render({"ul", _, items}), do: Enum.map_join(items, "\n", &render/1)

  defp render({"li", _, childs}), do: render(childs)

  defp render({"strong", _, children}), do: "**#{render(children)}**"

  defp render({"em", _, children}), do: "*#{render(children)}*"

  defp render({"code", _, children}), do: "`#{render(children)}`"

  defp render({"br", _, _}), do: "\n"

  defp render(text) when is_binary(text), do: text

  defp render({_, _, children}) when is_list(children), do: render(children)

  defp render(_), do: ""
end

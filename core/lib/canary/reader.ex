defmodule Canary.Reader do
  def title_from_html(html) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        document
        |> Floki.find("head title")
        |> Floki.text()

      _ ->
        nil
    end
  end

  def markdown_from_html(html) do
    html
    |> Canary.Native.html_to_md()
    |> String.trim()
  end

  def markdown_sections_from_html(html) do
    pattern = ~r/__CANARY__\(tag=([^,]+),id=([^,]+),text=([^)]+)\)/

    html
    |> Canary.Native.html_to_md_with_marker()
    |> String.split(pattern, include_captures: true)
    |> Enum.reduce({[], []}, fn item, {current_group, result} ->
      if Regex.match?(pattern, item) do
        {[item], result ++ [current_group]}
      else
        {current_group ++ [item], result}
      end
    end)
    |> then(fn {last_group, result} -> result ++ [last_group] end)
    |> Enum.reject(&(&1 == []))
    |> Enum.map(fn group ->
      case group do
        [content] ->
          %{content: String.trim(content)}

        [marker, content] ->
          [_, _tag, id, _title] = Regex.run(pattern, marker)
          %{content: String.trim(content), id: id}
      end
    end)
    |> Enum.reject(&(&1.content == ""))
  end

  def chunk_markdown(content) do
    content
    |> Canary.Native.chunk_markdown(1600)
    |> merge_small_chunks(1600 / 2)
  end

  defp merge_small_chunks(chunks, min_size) do
    chunks
    |> Enum.reduce({[], nil}, fn cur_chunk, {acc, prev_chunk} ->
      cond do
        is_nil(prev_chunk) -> {acc, cur_chunk}
        String.length(cur_chunk) < min_size -> {acc, prev_chunk <> "\n" <> cur_chunk}
        String.length(prev_chunk) < min_size -> {acc, prev_chunk <> "\n" <> cur_chunk}
        true -> {[prev_chunk | acc], cur_chunk}
      end
    end)
    |> then(fn {acc, last_chunk} -> [last_chunk | acc] end)
    |> Enum.reverse()
  end
end

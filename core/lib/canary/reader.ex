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

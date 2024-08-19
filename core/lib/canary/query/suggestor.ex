defmodule Canary.Query.Sugestor do
  @callback run(String.t()) :: {:ok, list(String.t())} | {:error, any()}

  def run(query), do: impl().run(query)

  def run!(query) do
    {:ok, result} = run(query)
    result
  end

  defp impl(), do: Canary.Query.Sugestor.Default
end

defmodule Canary.Query.Sugestor.Default do
  @behaviour Canary.Query.Sugestor

  def run(query) do
    query = clean(query)

    result =
      cond do
        empty?(query) -> []
        not question?(query) -> ["Can you tell me about '#{remove_question_mark(query)}'?"]
        count_words(query) > 2 -> [add_question_mark(query)]
        true -> []
      end

    {:ok, result}
  end

  defp clean(query) do
    query
    |> String.trim()
    |> String.downcase()
    |> String.capitalize()
  end

  defp empty?(query), do: query == ""

  defp question?(query) do
    query =
      query
      |> String.trim()
      |> String.downcase()

    String.ends_with?(query, "?") or
      query =~
        ~r/^(who|whom|whose|what|which|when|where|why|how|can|is|does|do|are|could|would|may|give)\b/
  end

  defp remove_question_mark(query) do
    if String.ends_with?(query, "?") do
      String.slice(query, 0..-2//-1)
    else
      query
    end
  end

  defp add_question_mark(query) do
    if String.ends_with?(query, "?") do
      query
    else
      query <> "?"
    end
  end

  defp count_words(query) do
    query |> String.split() |> length()
  end
end

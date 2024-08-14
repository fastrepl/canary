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

    result = cond do
      empty?(query) -> []
      question?(query) -> [add_question_mark(query)]
      true -> ["Can you tell me about '#{query}'?"]
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

    query =~ ~r/^(who|whom|whose|what|which|when|where|why|how)/
  end

  defp add_question_mark(query) do
    if String.ends_with?(query, "?") do
      query
    else
      query <> "?"
    end
  end
end

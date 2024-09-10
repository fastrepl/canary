defmodule Canary.Searcher.Result do
  @derive Jason.Encoder
  defstruct [:references, :suggestion]
  @type t :: %__MODULE__{references: map(), suggestion: map()}
end

defmodule Canary.Searcher do
  @callback run(any(), String.t()) :: {:ok, Canary.Searcher.Result.t()} | {:error, any()}

  def run(source, query) do
    with {:error, _} <- get_cache(source, query),
         {:ok, result} <- impl().run(source, query) do
      set_cache(source, query, result)
      {:ok, result}
    end
  end

  defp set_cache(source, query, result) do
    Cachex.put(:cache, key(source, query), result, ttl: :timer.minutes(5))
  end

  defp get_cache(source, query) do
    case Cachex.get(:cache, key(source, query)) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, hit} -> {:ok, hit}
    end
  end

  defp key(source, query), do: {source.id, query}
  defp impl(), do: Application.get_env(:canary, :searcher, Canary.Searcher.Default)
end

defmodule Canary.Searcher.Default do
  @behaviour Canary.Searcher

  def run(source, query) do
    if ai?(query) do
      Appsignal.instrument("ai_search", fn ->
        ai_search(source, query)
      end)
    else
      Appsignal.instrument("normal_search", fn ->
        normal_search(source, query)
      end)
    end
  end

  defp ai?(query) do
    query
    |> String.split(" ", trim: true)
    |> Enum.count() > 2
  end

  defp ai_search(source, query) do
    source = source |> Ash.load!(:documents)

    with {:ok, docs} <- Canary.Index.search_documents(source.id, query),
         {:ok, reranked} <-
           Canary.Reranker.run(
             query,
             Enum.dedup_by(docs, & &1.id),
             renderer: fn doc -> doc.content end,
             threshold: 0.05
           ) do
      {:ok,
       %Canary.Searcher.Result{
         references: %{source.name => reranked},
         suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
       }}
    end
  end

  defp normal_search(source, query) do
    source_id = source |> Map.get(:id)
    {:ok, results} = Canary.Index.search_documents(source_id, query)

    {:ok,
     %Canary.Searcher.Result{
       references: %{source.name => results},
       suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
     }}
  end
end

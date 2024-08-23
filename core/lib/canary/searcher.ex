defmodule Canary.Searcher do
  @callback run(any(), String.t()) :: {:ok, map()} | {:error, any()}

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
    ai = query |> String.split(" ", trim: true) |> Enum.count() > 2

    if ai do
      Appsignal.instrument("ai_search", fn ->
        ai_search(source, query)
      end)
    else
      Appsignal.instrument("normal_search", fn ->
        normal_search(source, query)
      end)
    end
  end

  defp ai_search(source, query) do
    source = source |> Ash.load!(:documents)
    docs_size = source.documents |> Enum.count()

    keywords =
      source.documents
      |> Enum.map(fn doc -> if doc.summary, do: doc.summary.keywords, else: [] end)
      |> Enum.flat_map(& &1)
      |> Enum.frequencies()
      |> Enum.map(fn {k, v} -> if v > 0.5 * docs_size, do: k, else: nil end)
      |> Enum.reject(&is_nil/1)

    with {:ok, analysis} <- Canary.Query.Understander.run(query, keywords),
         {:ok, docs} <- Canary.Index.batch_search_documents(source.id, analysis.keywords),
         {:ok, reranked} <-
           Canary.Reranker.run(
             query,
             Enum.dedup_by(docs, & &1.id),
             renderer: fn doc -> doc.content end,
             threshold: 0.05
           ) do
      {:ok,
       %{
         search: reranked,
         suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
       }}
    end
  end

  defp normal_search(source, query) do
    source_id = source |> Map.get(:id)
    {:ok, results} = Canary.Index.search_documents(source_id, query)

    {:ok,
     %{
       search: results,
       suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
     }}
  end
end

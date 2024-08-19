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
    Cachex.put(:cache, key(source, query), result, ttl: :timer.seconds(5))
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
    if ai, do: ai_search(source, query), else: normal_search(source, query)
  end

  defp ai_search(source, query) do
    source = source |> Ash.load!(:documents)
    docs_size = source.documents |> Enum.count()

    keywords =
      source.documents
      |> Enum.map(& &1.keywords)
      |> Enum.flat_map(& &1)
      |> Enum.frequencies()
      |> Enum.map(fn {k, v} -> if v > 0.5 * docs_size, do: k, else: nil end)
      |> Enum.reject(&is_nil/1)

    {:ok, analysis} = Canary.Query.Understander.run(query, keywords)
    {:ok, docs} = Canary.Index.batch_search_documents(source.id, analysis.keywords)
    docs = docs |> Enum.dedup_by(& &1.id)
    Canary.Reranker.run(analysis.query, docs, fn doc -> doc.content end)
  end

  defp normal_search(source, query) do
    source_id = source |> Map.get(:id)
    Canary.Index.search_documents(source_id, query)
  end
end

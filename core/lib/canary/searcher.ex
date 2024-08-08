defmodule Canary.Searcher do
  @callback run(any(), String.t()) :: {:ok, map()} | {:error, any()}

  def run(source, query), do: impl().run(source, query)
  defp impl(), do: Application.get_env(:canary, :searcher, Canary.Searcher.Default)
end

defmodule Canary.Searcher.Default do
  @behaviour Canary.Searcher

  def run(source, query) do
    ai = query |> String.split(" ", trim: true) |> Enum.count() > 3
    if ai, do: ai_search(source, query), else: normal_search(source, query)
  end

  defp ai_search(source, query) do
    source = source |> Ash.load!(:summaries)

    {:ok, analysis} = Canary.Query.Understander.run(query, Enum.join(source.summaries, "\n"))
    {:ok, docs} = Canary.Index.batch_search_documents(source.id, analysis.keywords)
    Canary.Reranker.run(analysis.query, docs, fn doc -> doc.content end)
  end

  defp normal_search(source, query) do
    source_id = source |> Map.get(:id)
    Canary.Index.search_documents(source_id, query)
  end
end

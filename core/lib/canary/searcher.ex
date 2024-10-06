defmodule Canary.Searcher do
  @callback run(list(any()), String.t(), keyword()) :: {:ok, list(map())} | {:error, any()}

  def run(sources, query, opts \\ []) do
    {cache, opts} = Keyword.pop(opts, :cache, false)

    if cache do
      with {:error, _} <- get_cache(sources, query, opts),
           {:ok, result} <- impl().run(sources, query, opts) do
        set_cache(sources, query, opts, result)
        {:ok, result}
      end
    else
      impl().run(sources, query, opts)
    end
  end

  defp set_cache(sources, query, opts, result) do
    Cachex.put(:cache, key(sources, query, opts), result, ttl: :timer.minutes(3))
  end

  defp get_cache(sources, query, opts) do
    case Cachex.get(:cache, key(sources, query, opts)) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, hit} -> {:ok, hit}
    end
  end

  defp key(sources, query, opts) do
    sources
    |> Enum.map(& &1.id)
    |> Enum.join(",")
    |> Kernel.<>(":" <> query)
    |> Kernel.<>(":" <> Jason.encode!(opts[:tags]))
  end

  defp impl(), do: Application.get_env(:canary, :searcher, Canary.Searcher.Default)
end

defmodule Canary.Searcher.Default do
  @behaviour Canary.Searcher

  require Ash.Query

  def run(sources, query, opts) do
    if ai?(query) do
      ai_search(sources, query, opts)
    else
      normal_search(sources, query, opts)
    end
  end

  defp ai?(query) do
    String.ends_with?(query, "?") or String.split(query, " ", trim: true) |> Enum.count() > 2
  end

  defp ai_search(sources, query, opts) do
    keywords = Canary.Query.Understander.keywords(sources)

    with {:ok, queries} = Canary.Query.Understander.run(query, keywords),
         {:ok, hits} <- Canary.Index.search(sources, queries, tags: opts[:tags]) do
      {:ok, transform(sources, hits)}
    end
  end

  defp normal_search(sources, query, opts) do
    {:ok, results} = Canary.Index.search(sources, [query], tags: opts[:tags])
    {:ok, transform(sources, results)}
  end

  defp transform(sources, search_results) do
    document_ids =
      search_results
      |> Enum.flat_map(fn %{hits: hits} -> Enum.map(hits, & &1.document_id) end)
      |> Enum.uniq()

    docs =
      Canary.Sources.Document
      |> Ash.Query.filter(id in ^document_ids)
      |> Ash.Query.build(select: [:id, :meta])
      |> Ash.read!()

    search_results
    |> Enum.flat_map(fn %{source_id: source_id, hits: hits} ->
      %Canary.Sources.Source{
        config: %Ash.Union{type: type}
      } = sources |> Enum.find(&(&1.id == source_id))

      original_docs_ids = hits |> Enum.map(& &1.document_id)

      hits
      |> Enum.group_by(& &1.document_id)
      |> Enum.map(fn {doc_id, chunks} ->
        doc = docs |> Enum.find(&(&1.id == doc_id))

        if not is_nil(doc) do
          parent_chunk =
            chunks
            |> Enum.find(fn chunk -> chunk.is_parent end)

          non_parent_chunks =
            chunks
            |> Enum.reject(fn chunk -> chunk.is_parent end)
            |> Enum.slice(0, 3)

          meta =
            case type do
              :webpage ->
                %{}

              :openapi ->
                %{}

              :github_issue ->
                %{closed: doc.meta.value.closed}

              :github_discussion ->
                %{closed: doc.meta.value.closed, answered: doc.meta.value.answered}
            end

          %{
            type: type,
            meta: meta,
            url: doc.meta.value.url,
            title: doc.meta.value.title,
            excerpt: if(parent_chunk, do: parent_chunk.excerpt, else: nil),
            sub_results: non_parent_chunks,
            document_id: doc_id
          }
        else
          nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.sort_by(&Enum.find_index(original_docs_ids, fn id -> id == &1.document_id end))
    end)
  end
end

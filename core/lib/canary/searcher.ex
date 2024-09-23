defmodule Canary.Searcher do
  @callback run(list(any()), String.t()) :: {:ok, list(map())} | {:error, any()}
  def run(sources, query, opts \\ []) do
    if opts[:cache] do
      with {:error, _} <- get_cache(sources, query),
           {:ok, result} <- impl().run(sources, query) do
        set_cache(sources, query, result)
        {:ok, result}
      end
    else
      impl().run(sources, query)
    end
  end

  defp set_cache(sources, query, result) do
    Cachex.put(:cache, key(sources, query), result, ttl: :timer.minutes(3))
  end

  defp get_cache(sources, query) do
    case Cachex.get(:cache, key(sources, query)) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, hit} -> {:ok, hit}
    end
  end

  defp key(sources, query) do
    sources
    |> Enum.map(& &1.id)
    |> Enum.join(",")
    |> Kernel.<>(":" <> query)
  end

  defp impl(), do: Application.get_env(:canary, :searcher, Canary.Searcher.Default)
end

defmodule Canary.Searcher.Default do
  @behaviour Canary.Searcher

  require Ash.Query

  def run(sources, query) do
    if ai?(query) do
      ai_search(sources, query)
    else
      normal_search(sources, query)
    end
  end

  defp ai?(query) do
    query
    |> String.split(" ", trim: true)
    |> Enum.count() > 2
  end

  defp ai_search(sources, query) do
    with {:ok, queries} = Canary.Query.Understander.run(sources, query),
         {:ok, results} <- Canary.Index.search(sources, queries) do
      {:ok, transform(sources, results)}
    end
  end

  defp normal_search(sources, query) do
    {:ok, results} = Canary.Index.search(sources, [query])
    {:ok, transform(sources, results)}
  end

  defp transform(sources, search_results) do
    document_ids =
      search_results
      |> Enum.flat_map(fn %{hits: hits} -> Enum.map(hits, & &1.document_id) end)

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

      hits
      |> Enum.group_by(& &1.document_id)
      |> Enum.map(fn {_, chunks} ->
        doc_id = chunks |> Enum.at(0) |> Map.get(:document_id)
        doc = docs |> Enum.find(&(&1.id == doc_id))

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
          sub_results: non_parent_chunks
        }
      end)
    end)
  end
end

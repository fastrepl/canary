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
    search_results
    |> Enum.flat_map(fn %{source_id: source_id, hits: hits} ->
      %Canary.Sources.Source{
        config: %Ash.Union{type: type}
      } = sources |> Enum.find(&(&1.id == source_id))

      hits
      |> Enum.group_by(& &1.document_id)
      |> Enum.map(fn {_, chunks} ->
        first = chunks |> Enum.at(0)

        %{
          # TODO: duplicated, and too many subresults
          type: type,
          meta: %{},
          url: first.url,
          title: first.title,
          excerpt: first.excerpt,
          sub_results: chunks
        }
      end)
    end)
  end
end

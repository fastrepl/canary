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

  def run(sources, query, _opts) do
    {:ok, groups} =
      Canary.Index.Trieve.Client.search(query, source_ids: Enum.map(sources, & &1.id))

    matches =
      groups
      |> Enum.map(fn %{"group" => group, "chunks" => chunks} ->
        chunks =
          chunks
          |> Enum.map(fn chunk ->
            %{
              "chunk" => %{"metadata" => meta, "link" => url},
              "highlights" => highlights
            } = chunk

            %{
              meta: meta,
              url: url,
              title: meta["title"],
              excerpt: Enum.at(highlights, 0, nil)
            }
          end)

        meta = group["metadata"]

        %{
          type: meta["type"],
          meta: %{},
          url: meta["url"],
          title: meta["title"],
          sub_results: chunks
        }
      end)

    {:ok, matches}
  end
end

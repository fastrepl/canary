defmodule Canary.Searcher do
  @callback run(list(any()), String.t()) :: {:ok, Canary.Searcher.Result.t()} | {:error, any()}
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
      Appsignal.instrument("normal_search", fn ->
        normal_search(sources, query)
      end)
    else
      Appsignal.instrument("normal_search", fn ->
        normal_search(sources, query)
      end)
    end
  end

  defp ai?(query) do
    query
    |> String.split(" ", trim: true)
    |> Enum.count() > 2
  end

  defp normal_search(sources, query) do
    {:ok, results} = Canary.Index.search(sources, query)

    ret =
      results
      |> Enum.map(fn %{source_id: source_id, hits: hits} ->
        %Canary.Sources.Source{
          name: name,
          config: %Ash.Union{type: type}
        } = sources |> Enum.find(&(&1.id == source_id))

        %{name: name, type: type, hits: hits}
      end)

    {:ok, ret}
  end
end

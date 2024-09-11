defmodule Canary.Searcher.Result do
  @derive Jason.Encoder
  defstruct [:references, :suggestion]
  @type t :: %__MODULE__{references: map(), suggestion: map()}
end

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
      Appsignal.instrument("ai_search", fn ->
        ai_search(sources, query)
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

  defp ai_search(sources, query) do
    with {:ok, docs} <- Canary.Index.search(sources, query),
         {:ok, reranked} <-
           Canary.Reranker.run(
             query,
             Enum.dedup_by(docs, & &1.id),
             renderer: fn doc -> doc.content end,
             threshold: 0.05
           ) do
      result = %Canary.Searcher.Result{
        references: %{"Doc" => reranked},
        suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
      }

      {:ok, result}
    end
  end

  defp normal_search(sources, query) do
    {:ok, results} = Canary.Index.search(sources, query)

    references =
      results
      |> Enum.reject(&Enum.empty?/1)
      |> Enum.reduce(%{}, fn matches, acc ->
        source = sources |> Enum.find(&(&1.id == Enum.at(matches, 0).source_id))
        acc |> Map.put(source.name, matches)
      end)

    result = %Canary.Searcher.Result{
      references: references,
      suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
    }

    {:ok, result}
  end
end

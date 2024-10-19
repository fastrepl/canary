defmodule Canary.Searcher do
  @callback run(String.t(), keyword()) :: {:ok, list(map())} | {:error, any()}

  def run(query, opts \\ []) do
    {cache, opts} = Keyword.pop(opts, :cache, false)

    if cache do
      with {:error, _} <- get_cache(query, opts),
           {:ok, result} <- impl().run(query, opts) do
        set_cache(query, opts, result)
        {:ok, result}
      end
    else
      impl().run(query, opts)
    end
  end

  defp set_cache(query, opts, result) do
    Cachex.put(:cache, key(query, opts), result, ttl: :timer.minutes(3))
  end

  defp get_cache(query, opts) do
    case Cachex.get(:cache, key(query, opts)) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, hit} -> {:ok, hit}
    end
  end

  defp key(query, opts) do
    query
    |> Kernel.<>(":" <> Jason.encode!(opts[:tags]))
    |> Kernel.<>(":" <> Jason.encode!(opts[:source_ids]))
  end

  defp impl(), do: Application.get_env(:canary, :searcher, Canary.Searcher.Default)
end

defmodule Canary.Searcher.Default do
  @behaviour Canary.Searcher

  require Ash.Query

  def run(query, opts) do
    with {:ok, groups} <- Canary.Index.Trieve.Client.search(query, opts) do
      matches =
        groups
        |> Enum.map(&transform_result/1)
        |> Enum.reject(&is_nil/1)

      {:ok, matches}
    end
  end

  defp transform_result(%{
         "group" => %{"metadata" => %{"type" => "webpage"} = group_meta},
         "chunks" => chunks
       }) do
    chunks =
      chunks
      |> Enum.map(fn chunk ->
        %{
          "chunk" => %{"metadata" => meta, "link" => url},
          "highlights" => highlights
        } = chunk

        cond do
          meta["title"] == group_meta["title"] ->
            nil

          Enum.at(highlights, 0, nil) == nil ->
            nil

          true ->
            %{
              meta: meta,
              url: url,
              title: meta["title"],
              excerpt: Enum.at(highlights, 0)
            }
        end
      end)
      |> Enum.reject(&is_nil/1)

    %{
      type: group_meta["type"],
      url: group_meta["url"],
      title: group_meta["title"],
      meta: %{},
      sub_results: chunks
    }
  end

  defp transform_result(%{
         "group" => %{"metadata" => %{"type" => "github_issue"} = group_meta},
         "chunks" => chunks
       }) do
    chunks =
      chunks
      |> Enum.map(fn chunk ->
        %{
          "chunk" => %{"metadata" => _meta, "link" => url},
          "highlights" => highlights
        } = chunk

        if Enum.at(highlights, 0) do
          %{
            url: url,
            excerpt: Enum.at(highlights, 0)
          }
        else
          nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    %{
      type: group_meta["type"],
      url: group_meta["url"],
      title: group_meta["title"],
      meta: %{
        closed: group_meta["closed"]
      },
      sub_results: chunks
    }
  end

  defp transform_result(%{
         "group" => %{"metadata" => %{"type" => "github_discussion"} = group_meta},
         "chunks" => chunks
       }) do
    chunks =
      chunks
      |> Enum.map(fn chunk ->
        %{
          "chunk" => %{"metadata" => _meta, "link" => url},
          "highlights" => highlights
        } = chunk

        if Enum.at(highlights, 0) do
          %{
            url: url,
            excerpt: Enum.at(highlights, 0)
          }
        else
          nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    %{
      type: group_meta["type"],
      url: group_meta["url"],
      title: group_meta["title"],
      meta: %{
        closed: group_meta["closed"],
        answered: group_meta["answered"]
      },
      sub_results: chunks
    }
  end
end

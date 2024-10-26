defmodule Canary.Interface.Search do
  @callback run(any(), String.t(), keyword()) :: {:ok, list(map())} | {:error, any()}

  def run(_, _, opts \\ [])
  def run(nil, _, _), do: {:ok, []}
  def run(_, "", _), do: {:ok, []}

  def run(project, query, opts) do
    {cache, opts} = Keyword.pop(opts, :cache, false)

    if cache do
      with {:error, _} <- get_cache(project, query, opts),
           {:ok, result} <- impl().run(project, query, opts) do
        set_cache(project, query, opts, result)
        {:ok, result}
      end
    else
      impl().run(project, query, opts)
    end
  end

  defp set_cache(project, query, opts, result) do
    Cachex.put(:cache, key(project, query, opts), result, ttl: :timer.minutes(3))
  end

  defp get_cache(project, query, opts) do
    case Cachex.get(:cache, key(project, query, opts)) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, hit} -> {:ok, hit}
    end
  end

  defp key(project, query, opts) do
    project.id
    |> Kernel.<>(":" <> query)
    |> Kernel.<>(":" <> Jason.encode!(opts[:tags]))
  end

  defp impl(),
    do: Application.get_env(:canary, :interface_search, Canary.Interface.Search.Default)
end

defmodule Canary.Interface.Search.Default do
  @behaviour Canary.Interface.Search

  require Ash.Query
  alias Canary.Index.Trieve
  alias Canary.Accounts.Project

  def run(%Project{} = project, query, opts) do
    with {:ok, groups} <- Trieve.client(project) |> Trieve.search(query, opts) do
      matches =
        groups
        |> Enum.map(&transform_result_safe/1)
        |> Enum.reject(&is_nil/1)

      {:ok, matches}
    end
  end

  defp transform_result_safe(group) do
    try do
      transform_result(group)
    rescue
      exception ->
        Sentry.Context.set_extra_context(%{search_result_group: group})
        Sentry.capture_exception(exception, stacktrace: __STACKTRACE__)

        nil
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

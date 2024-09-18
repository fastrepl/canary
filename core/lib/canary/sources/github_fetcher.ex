defmodule Canary.Sources.GithubFetcher do
  defp client() do
    Canary.graphql_client(
      url: "https://api.github.com/graphql",
      auth: {:bearer, System.get_env("GITHUB_API_KEY")}
    )
  end

  def run_all(query, variables) do
    Stream.unfold(nil, fn
      :stop ->
        nil

      cursor ->
        case run(query, Map.put(variables, :cursor, cursor)) do
          {:ok, data} ->
            resource = get_resource(data)
            page_info = data["repository"][resource]["pageInfo"]
            nodes = data["repository"][resource]["nodes"]

            if page_info["hasNextPage"] do
              {nodes, page_info["endCursor"]}
            else
              {nodes, :stop}
            end

          {:try_after_s, seconds} ->
            Process.sleep(seconds * 1000)
            {[], cursor}

          {:error, errors} ->
            IO.inspect(errors)
            {[], :stop}
        end
    end)
    |> Stream.flat_map(& &1)
    |> Enum.to_list()
  end

  def run(query, variables) do
    case client() |> Req.post(graphql: {query, variables}) do
      {:ok, %{status: 200, body: %{"data" => data}}} ->
        {:ok, data}

      # https://docs.github.com/en/graphql/overview/rate-limits-and-node-limits-for-the-graphql-api#exceeding-the-rate-limit
      {:ok, %{status: 403, headers: headers}} ->
        if headers["x-ratelimit-remaining"] == "0" and length(headers["x-ratelimit-reset"]) == 1 do
          {:try_after_s, String.to_integer(Enum.at(headers["x-ratelimit-reset"], 0))}
        else
          {:try_after_s, 60}
        end

      {:ok, %{status: 200, body: %{"errors" => errors}}} ->
        {:error, errors}

      {:ok, res} ->
        {:error, res}

      {:error, error} ->
        {:error, error}
    end
  end

  defp get_resource(data) do
    cond do
      Map.has_key?(data["repository"], "issues") -> "issues"
      Map.has_key?(data["repository"], "discussions") -> "discussions"
      true -> raise "Unknown resource"
    end
  end
end

defmodule Canary.Sources.GithubIssue.FetcherResult do
  defstruct [
    :node_id,
    :title,
    :content,
    :url,
    :created_at,
    :author_name,
    :author_avatar_url,
    :comment,
    :closed
  ]

  @type t :: %__MODULE__{
          node_id: String.t(),
          title: String.t(),
          content: String.t(),
          url: String.t(),
          created_at: DateTime.t(),
          author_name: String.t(),
          author_avatar_url: String.t(),
          comment: boolean(),
          closed: boolean()
        }
end

defmodule Canary.Sources.GithubIssue.Fetcher do
  @default_issue_n 100
  @default_comment_n 100

  alias Canary.Sources.Source
  alias Canary.Sources.GithubIssue

  defp client() do
    Canary.graphql_client(
      url: "https://api.github.com/graphql",
      auth: {:bearer, System.get_env("GITHUB_API_KEY")}
    )
  end

  def run(%Source{config: %Ash.Union{type: :github_issue, value: %GithubIssue.Config{} = config}}) do
    {:ok, fetch_all(config.owner, config.repo)}
  end

  defp fetch_all(owner, repo) do
    Stream.unfold(nil, fn
      :stop ->
        nil

      cursor ->
        case fetch_page(owner, repo, cursor) do
          {:ok, data} ->
            page_info = data["repository"]["issues"]["pageInfo"]
            nodes = data["repository"]["issues"]["nodes"]

            if page_info["hasNextPage"] do
              {nodes, page_info["endCursor"]}
            else
              {nodes, :stop}
            end

          {:try_after_s, seconds} ->
            Process.sleep(seconds * 1000)
            {[], cursor}

          {:error, _} ->
            {[], :stop}
        end
    end)
    |> Stream.flat_map(fn nodes -> Enum.map(nodes, &transform_issue_node/1) end)
    |> Enum.to_list()
  end

  defp fetch_page(owner, repo, cursor) do
    result =
      client()
      |> Req.post(
        graphql:
          {"""
            query ($owner: String!, $repo: String!, $issue_n: Int!, $comment_n: Int!, $cursor: String) {
              repository(owner: $owner, name: $repo) {
                issues(first: $issue_n, orderBy: {field: UPDATED_AT, direction: DESC}, after: $cursor) {
                  pageInfo {
                    endCursor
                    hasNextPage
                  }
                  nodes {
                    id
                    bodyUrl
                    author {
                      login
                      avatarUrl
                    }
                    title
                    body
                    closed
                    createdAt
                    comments(last: $comment_n) {
                      nodes {
                        id
                        url
                        author {
                          login
                          avatarUrl
                        }
                        body
                      }
                    }
                  }
                }
              }
            }
           """,
           %{
             issue_n: @default_issue_n,
             comment_n: @default_comment_n,
             repo: repo,
             owner: owner,
             cursor: cursor
           }}
      )

    case result do
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

      {:error, error} ->
        {:error, error}
    end
  end

  defp transform_issue_node(issue) do
    top = %GithubIssue.FetcherResult{
      node_id: issue["id"],
      title: issue["title"],
      content: issue["body"],
      url: issue["bodyUrl"],
      created_at: issue["createdAt"],
      author_name: issue["author"]["login"],
      author_avatar_url: issue["author"]["avatarUrl"],
      comment: false,
      closed: issue["closed"]
    }

    comments =
      issue["comments"]["nodes"]
      |> Enum.map(fn comment ->
        %GithubIssue.FetcherResult{
          node_id: comment["id"],
          title: "",
          content: comment["body"],
          url: comment["url"],
          created_at: comment["createdAt"],
          author_name: comment["author"]["login"],
          author_avatar_url: comment["author"]["avatarUrl"],
          comment: true
        }
      end)

    [top | comments]
  end
end

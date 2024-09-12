defmodule Canary.Sources.GithubIssue.FetcherResult do
  defstruct [
    :node_id,
    :title,
    :content,
    :url,
    :created_at,
    :author_name,
    :author_avatar_url,
    :comment
  ]

  @type t :: %__MODULE__{
          node_id: String.t(),
          title: String.t(),
          content: String.t(),
          url: String.t(),
          created_at: DateTime.t(),
          author_name: String.t(),
          author_avatar_url: String.t(),
          comment: boolean()
        }
end

defmodule Canary.Sources.GithubIssue.Fetcher do
  @default_issue_n 5
  @default_comment_n 5

  alias Canary.Sources.Source
  alias Canary.Sources.GithubIssue

  defp client() do
    Canary.graphql_client(
      url: "https://api.github.com/graphql",
      auth: {:bearer, System.get_env("GITHUB_API_KEY")}
    )
  end

  def run(%Source{config: %Ash.Union{type: :github_issue, value: %GithubIssue.Config{} = config}}) do
    result =
      client()
      |> Req.post(
        graphql:
          {"""
            query ($owner: String!, $repo: String!, $issue_n: Int!, $comment_n: Int!) {
              repository(owner: $owner, name: $repo) {
                issues(first: $issue_n, orderBy: {field: UPDATED_AT, direction: DESC}) {
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
           Map.merge(
             %{issue_n: @default_issue_n, comment_n: @default_comment_n},
             %{repo: config.repo, owner: config.owner}
           )}
      )

    case result do
      {:ok, %{status: 200, body: %{"data" => data}}} ->
        {:ok, process(data)}

      # https://docs.github.com/en/graphql/overview/rate-limits-and-node-limits-for-the-graphql-api#exceeding-the-rate-limit
      {:ok, %{status: 403, headers: headers}} ->
        if headers["x-ratelimit-remaining"] == "0" and length(headers["x-ratelimit-reset"]) == 1 do
          {:try_after_s, String.to_integer(Enum.at(headers["x-ratelimit-reset"], 0))}
        else
          {:try_after_s, 60}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp process(data) do
    issues = data["repository"]["issues"]["nodes"]

    issues
    |> Enum.map(fn issue ->
      top = %GithubIssue.FetcherResult{
        node_id: issue["id"],
        title: issue["title"],
        content: issue["body"],
        url: issue["bodyUrl"],
        created_at: issue["createdAt"],
        author_name: issue["author"]["login"],
        author_avatar_url: issue["author"]["avatarUrl"],
        comment: false
      }

      comments =
        issue["comments"]["nodes"]
        |> Enum.map(fn comment ->
          %GithubIssue.FetcherResult{
            node_id: comment["id"],
            title: "NONE",
            content: comment["body"],
            url: comment["url"],
            created_at: comment["createdAt"],
            author_name: comment["author"]["login"],
            author_avatar_url: comment["author"]["avatarUrl"],
            comment: true
          }
        end)

      [top | comments]
    end)
  end
end

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
  alias Canary.Sources.GithubFetcher

  def run(%Source{config: %Ash.Union{type: :github_issue, value: %GithubIssue.Config{} = config}}) do
    query = """
    query ($owner: String!, $repo: String!, $issue_n: Int!, $comment_n: Int!, $since: DateTime!, $cursor: String) {
      repository(owner: $owner, name: $repo) {
        issues(first: $issue_n, orderBy: {field: UPDATED_AT, direction: DESC}, filterBy: {since: $since}, after: $cursor) {
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
    """

    variables = %{
      owner: config.owner,
      repo: config.repo,
      issue_n: @default_issue_n,
      comment_n: @default_comment_n,
      cursor: nil,
      since: DateTime.utc_now() |> DateTime.add(-365, :day) |> DateTime.to_iso8601()
    }

    nodes = GithubFetcher.run_all(query, variables)
    {:ok, Enum.map(nodes, &transform_issue_node/1)}
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

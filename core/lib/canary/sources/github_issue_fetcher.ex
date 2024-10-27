defmodule Canary.Sources.GithubIssue.FetcherResult do
  alias Canary.Sources.GithubIssue

  defstruct [:root, :items]
  @type t :: %__MODULE__{root: GithubIssue.Root.t(), items: list(GithubIssue.Item.t())}
end

defmodule Canary.Sources.GithubIssue do
  @fields [
    :node_id,
    :url,
    :content,
    :created_at,
    :author_name,
    :author_avatar_url,
    :num_reactions
  ]

  def base_fields(), do: @fields
end

defmodule Canary.Sources.GithubIssue.Root do
  alias Canary.Sources.GithubIssue

  defstruct GithubIssue.base_fields() ++ [:title, :closed]

  @type t :: %__MODULE__{
          node_id: String.t(),
          url: String.t(),
          content: String.t(),
          created_at: DateTime.t(),
          author_name: String.t(),
          author_avatar_url: String.t(),
          title: String.t(),
          closed: boolean()
        }
end

defmodule Canary.Sources.GithubIssue.Item do
  alias Canary.Sources.GithubIssue

  defstruct GithubIssue.base_fields()

  @type t :: %__MODULE__{
          node_id: String.t(),
          url: String.t(),
          content: String.t(),
          created_at: DateTime.t(),
          author_name: String.t(),
          author_avatar_url: String.t()
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
                createdAt
                author {
                  login
                  avatarUrl
                }
                body
                reactions {
                  totalCount
                }
              }
            }
            reactions {
              totalCount
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
      since: DateTime.utc_now() |> DateTime.add(-180, :day) |> DateTime.to_iso8601()
    }

    stream =
      GithubFetcher.run_all(query, variables)
      |> Stream.map(&transform_issue_node/1)

    {:ok, stream}
  end

  defp transform_issue_node(issue) do
    root = %GithubIssue.Root{
      node_id: issue["id"],
      url: issue["bodyUrl"],
      content: issue["body"],
      created_at: issue["createdAt"],
      author_name: issue["author"]["login"],
      author_avatar_url: issue["author"]["avatarUrl"],
      title: issue["title"],
      closed: issue["closed"],
      num_reactions: issue["reactions"]["totalCount"]
    }

    items =
      issue["comments"]["nodes"]
      |> Enum.map(fn comment ->
        %GithubIssue.Item{
          node_id: comment["id"],
          url: comment["url"],
          content: comment["body"],
          created_at: comment["createdAt"],
          author_name: comment["author"]["login"],
          author_avatar_url: comment["author"]["avatarUrl"],
          num_reactions: comment["reactions"]["totalCount"]
        }
      end)

    %GithubIssue.FetcherResult{root: root, items: items}
  end
end

defmodule Canary.Sources.GithubDiscussion.FetcherResult do
  defstruct [
    :node_id,
    :title,
    :content,
    :url,
    :created_at,
    :author_name,
    :author_avatar_url,
    :comment,
    :closed,
    :answered
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
          closed: boolean(),
          answered: boolean()
        }
end

defmodule Canary.Sources.GithubDiscussion.Fetcher do
  @default_discussion_n 100
  @default_comment_n 100

  alias Canary.Sources.Source
  alias Canary.Sources.GithubDiscussion
  alias Canary.Sources.GithubFetcher

  def run(%Source{
        config: %Ash.Union{type: :github_discussion, value: %GithubDiscussion.Config{} = config}
      }) do
    query = """
    query ($owner: String!, $repo: String!, $discussion_n: Int!, $comment_n: Int!, $cursor: String) {
      repository(owner: $owner, name: $repo) {
        discussions(first: $discussion_n, orderBy: {field: UPDATED_AT, direction: DESC}, after: $cursor) {
          pageInfo {
            endCursor
            hasNextPage
          }
          nodes {
            id
            url
            author {
              login
              avatarUrl
            }
            upvoteCount
            title
            body
            closed
            isAnswered
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
                createdAt
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
      discussion_n: @default_discussion_n,
      comment_n: @default_comment_n,
      cursor: nil
    }

    stream =
      GithubFetcher.run_all(query, variables)
      |> Stream.map(&transform_discussion_node/1)

    {:ok, stream}
  end

  defp transform_discussion_node(discussion) do
    top = %GithubDiscussion.FetcherResult{
      node_id: discussion["id"],
      title: discussion["title"],
      content: discussion["body"],
      url: discussion["url"],
      created_at: discussion["createdAt"],
      author_name: discussion["author"]["login"],
      author_avatar_url: discussion["author"]["avatarUrl"],
      comment: false,
      closed: discussion["closed"],
      answered: discussion["isAnswered"]
    }

    comments =
      discussion["comments"]["nodes"]
      |> Enum.map(fn comment ->
        %GithubDiscussion.FetcherResult{
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

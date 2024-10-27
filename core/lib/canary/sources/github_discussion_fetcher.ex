defmodule Canary.Sources.GithubDiscussion.FetcherResult do
  alias Canary.Sources.GithubDiscussion

  defstruct [:root, :items]
  @type t :: %__MODULE__{root: GithubDiscussion.Root.t(), items: list(GithubDiscussion.Item.t())}
end

defmodule Canary.Sources.GithubDiscussion do
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

defmodule Canary.Sources.GithubDiscussion.Root do
  alias Canary.Sources.GithubDiscussion

  defstruct GithubDiscussion.base_fields() ++ [:title, :closed, :answered]

  @type t :: %__MODULE__{
          node_id: String.t(),
          url: String.t(),
          content: String.t(),
          created_at: DateTime.t(),
          author_name: String.t(),
          author_avatar_url: String.t(),
          title: String.t(),
          closed: boolean(),
          answered: boolean()
        }
end

defmodule Canary.Sources.GithubDiscussion.Item do
  alias Canary.Sources.GithubDiscussion

  defstruct GithubDiscussion.base_fields()

  @type t :: %__MODULE__{
          node_id: String.t(),
          url: String.t(),
          content: String.t(),
          created_at: DateTime.t(),
          author_name: String.t(),
          author_avatar_url: String.t()
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
    root = %GithubDiscussion.Root{
      node_id: discussion["id"],
      url: discussion["url"],
      content: discussion["body"],
      created_at: discussion["createdAt"],
      author_name: discussion["author"]["login"],
      author_avatar_url: discussion["author"]["avatarUrl"],
      title: discussion["title"],
      closed: discussion["closed"],
      answered: discussion["isAnswered"],
      num_reactions: discussion["reactions"]["totalCount"]
    }

    items =
      discussion["comments"]["nodes"]
      |> Enum.map(fn comment ->
        %GithubDiscussion.Item{
          node_id: comment["id"],
          url: comment["url"],
          content: comment["body"],
          created_at: comment["createdAt"],
          author_name: comment["author"]["login"],
          author_avatar_url: comment["author"]["avatarUrl"],
          num_reactions: comment["reactions"]["totalCount"]
        }
      end)

    %GithubDiscussion.FetcherResult{root: root, items: items}
  end
end

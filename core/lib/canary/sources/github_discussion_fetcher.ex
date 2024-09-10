defmodule Canary.Sources.GithubDiscussion.FetcherResult do
  defstruct [
    :title,
    :content,
    :url,
    :created_at,
    :author_name,
    :author_avatar_url,
    :comment
  ]

  @type t :: %__MODULE__{
          title: String.t(),
          content: String.t(),
          url: String.t(),
          created_at: DateTime.t(),
          author_name: String.t(),
          author_avatar_url: String.t(),
          comment: boolean()
        }
end

defmodule Canary.Sources.GithubDiscussion.Fetcher do
  @default_discussion_n 50
  @default_comment_n 50

  defp client() do
    Canary.graphql_client(
      url: "https://api.github.com/graphql",
      auth: {:bearer, System.get_env("GITHUB_API_KEY")}
    )
  end

  def run(%{owner: _, repo: _} = input) do
    result =
      client()
      |> Req.post(
        graphql:
          {"""
            query ($owner: String!, $repo: String!, $discussion_n: Int!, $comment_n: Int!) {
              repository(owner: $owner, name: $repo) {
                discussions(first: $discussion_n, orderBy: {field: UPDATED_AT, direction: DESC}) {
                  nodes {
                    id
                    url
                    author {
                      login
                      avatarUrl
                    }
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
                      }
                    }
                  }
                }
              }
            }
           """,
           Map.merge(%{discussion_n: @default_discussion_n, comment_n: @default_comment_n}, input)}
      )

    case result do
      {:ok, %{status: 200, body: %{"data" => data}}} ->
        {:ok, to_document(data)}

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

  defp to_document(data) do
    discussions = data["repository"]["discussions"]["nodes"]

    discussions
    |> Enum.flat_map(fn discussion ->
      top = %Canary.Sources.GithubDiscussion.Chunk{
        title: discussion["title"],
        content: discussion["body"],
        url: discussion["url"],
        created_at: discussion["createdAt"],
        author_name: discussion["author"]["login"],
        author_avatar_url: discussion["author"]["avatarUrl"],
        comment: false
      }

      comments =
        discussion["comments"]["nodes"]
        |> Enum.map(fn comment ->
          %Canary.Sources.GithubDiscussion.Chunk{
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
    end)
  end
end

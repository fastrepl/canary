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

  defp client() do
    Canary.graphql_client(
      url: "https://api.github.com/graphql",
      auth: {:bearer, System.get_env("GITHUB_API_KEY")}
    )
  end

  def run(%Source{
        config: %Ash.Union{type: :github_discussion, value: %GithubDiscussion.Config{} = config}
      }) do
    {:ok, fetch_all(config.owner, config.repo)}
  end

  def fetch_all(owner, repo) do
    Stream.unfold(nil, fn
      :stop ->
        nil

      cursor ->
        case fetch_page(owner, repo, cursor) do
          {:ok, data} ->
            page_info = data["repository"]["discussions"]["pageInfo"]
            nodes = data["repository"]["discussions"]["nodes"]

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
    |> Stream.flat_map(fn nodes -> Enum.map(nodes, &transform_discussion_node/1) end)
    |> Enum.to_list()
  end

  def fetch_page(owner, repo, cursor) do
    result =
      client()
      |> Req.post(
        graphql:
          {"""
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
           %{
             discussion_n: @default_discussion_n,
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

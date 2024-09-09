defmodule Canary.Sources.GithubIssue.Fetcher do
  @default_issue_n 50
  @default_comment_n 50

  alias Canary.Sources.Source
  alias Canary.Sources.GithubIssue

  defp client() do
    Canary.graphql_client(
      url: "https://api.github.com/graphql",
      auth: {:bearer, System.get_env("GITHUB_TOKEN")}
    )
  end

  def run(%Source{
        id: source_id,
        config: %Ash.Union{type: :github_issue, value: %GithubIssue.Config{} = config}
      }) do
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
        {:ok, process(source_id, data)}

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

  # THIS is kind fo wrong because we need to call "Action" to create Chunk
  # Here, we should think this as "Creating Document", but rather
  # find existing documents, and dispatch "create/update/destroy" to Document resource
  defp process(source_id, data) do
    data = data["repository"]["issues"]["nodes"]

    top = %Canary.Sources.GithubIssue.Chunk{
      node_id: data["id"],
      title: data["title"],
      content: data["body"],
      url: data["bodyUrl"],
      created_at: data["createdAt"],
      author_name: data["author"]["login"],
      author_avatar_url: data["author"]["avatarUrl"],
      comment: false
    }

    comments =
      data["comments"]["nodes"]
      |> Enum.map(fn comment ->
        %Canary.Sources.GithubIssue.Chunk{
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

    input = [top | comments]

    existing =
      Canary.Sources.Document.find(
        source_id,
        :github_issue,
        :node_id,
        input |> Enum.map(& &1.node_id)
      )

    existing
  end
end

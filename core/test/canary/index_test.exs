defmodule Canary.Test.Index do
  use Canary.DataCase

  alias Canary.Index
  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue
  alias Canary.Sources.GithubDiscussion

  test "ensure" do
    :ok = Index.Collection.ensure(:webpage)
    :ok = Index.Collection.ensure(:github_issue)
    :ok = Index.Collection.ensure(:github_discussion)
    {:ok, _} = Index.Stopword.ensure()
  end

  test "insert and search" do
    source_webpage = %Canary.Sources.Source{
      id: Ash.UUID.generate(),
      config: %Ash.Union{type: :webpage}
    }

    source_github_issue = %Canary.Sources.Source{
      id: Ash.UUID.generate(),
      config: %Ash.Union{type: :github_issue}
    }

    source_github_discussion = %Canary.Sources.Source{
      id: Ash.UUID.generate(),
      config: %Ash.Union{type: :github_discussion}
    }

    {:ok, _} =
      Index.insert_document(%Webpage.Chunk{
        source_id: source_webpage.id,
        index_id: Ash.UUID.generate(),
        title: "title",
        content: "content",
        url: "https://example.com",
        keywords: ["keyword1", "keyword2"]
      })

    {:ok, _} =
      Index.insert_document(%GithubIssue.Chunk{
        source_id: source_github_issue.id,
        index_id: Ash.UUID.generate(),
        node_id: "node_id",
        title: "title",
        content: "content",
        created_at: DateTime.utc_now(),
        author_name: "author_name",
        author_avatar_url: "author_avatar_url",
        comment: false
      })

    {:ok, _} =
      Index.insert_document(%GithubDiscussion.Chunk{
        source_id: source_github_discussion.id,
        index_id: Ash.UUID.generate(),
        title: "title",
        content: "content",
        url: "https://github.com/fastrepl/canary/discussions/1",
        created_at: DateTime.utc_now(),
        author_name: "author_name",
        author_avatar_url: "author_avatar_url",
        comment: false
      })

    {:ok, docs} =
      Index.search(
        [source_webpage, source_github_issue, source_github_discussion],
        "title"
      )

    assert length(docs) == 3
  end
end

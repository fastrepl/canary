defmodule Canary.Test.Index do
  use Canary.DataCase
  alias Canary.Index

  test "search" do
    source_id = Ash.UUID.generate()

    {:ok, doc_1} =
      Index.insert_document(%Index.Document{
        id: Ash.UUID.generate(),
        source_id: source_id,
        title: "title",
        content: "content",
        tags: ["tag1", "tag2"]
      })

    {:ok, doc_2} =
      Index.insert_document(%Index.Document{
        id: Ash.UUID.generate(),
        source_id: source_id,
        title: "something",
        content: "content",
        embedding: List.duplicate(1.0, 384),
        tags: ["tag1", "tag2"]
      })

    {:ok, doc_3} =
      Index.insert_document(%Index.Document{
        id: Ash.UUID.generate(),
        source_id: source_id,
        title: "else",
        content: "content",
        embedding: List.duplicate(0.1, 384),
        tags: ["tag1", "tag2"]
      })

    {:ok, docs} = Index.search_documents([source_id], "title")
    assert length(docs) == 1
    assert Enum.at(docs, 0).id == doc_1["id"]

    {:ok, docs} =
      Index.search_documents([source_id], "aaaaa", embedding: List.duplicate(1.0, 384))

    assert length(docs) == 2
    assert Enum.at(docs, 0).id == doc_2["id"]
    assert Enum.at(docs, 1).id == doc_3["id"]
  end
end

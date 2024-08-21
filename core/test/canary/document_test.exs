defmodule Canary.Test.Document do
  use Canary.DataCase, async: false
  import Canary.AccountsFixtures

  import Mox
  setup :verify_on_exit!

  setup do
    account = account_fixture()
    source = Canary.Sources.Source.create!(account, "https://example.com")

    Canary.Index.ensure_collection()
    on_exit(fn -> Canary.Index.delete_collection() end)

    %{source: source}
  end

  test "create", %{source: source} do
    {:ok, docs} = Canary.Index.list_documents(source.id)
    assert length(docs) == 0

    Canary.AI.Mock
    |> expect(:chat, 2, fn _, _ -> {:ok, "completion"} end)

    create_result =
      Ash.bulk_create(
        [
          %{
            source_id: source.id,
            title: "hello",
            url: "/a",
            html: "<h1>hello</h1>"
          },
          %{
            source_id: source.id,
            title: "hello",
            url: "/b",
            html: "<h1>hello</h1>"
          }
        ],
        Canary.Sources.Document,
        :create,
        return_errors?: true,
        return_records?: true
      )

    assert create_result.status == :success
    assert Canary.Repo.all(Canary.Sources.Document) |> length() == 0 + 2

    {:ok, docs} = Canary.Index.list_documents(source.id)
    assert length(docs) == 0 + 2

    some_chunk = create_result.records |> Enum.at(1) |> Map.get(:chunks) |> Enum.at(0)
    found_doc = Canary.Sources.Document.find_by_chunk_index_id!(some_chunk.index_id)
    assert found_doc.id == create_result.records |> Enum.at(1) |> Map.get(:id)

    destroy_target = create_result.records |> Enum.at(1)
    delete_result = Ash.bulk_destroy([destroy_target], :destroy, %{}, return_errors?: true)
    assert delete_result.status == :success

    assert Canary.Repo.all(Canary.Sources.Document) |> length() == 2 - 1
    {:ok, docs} = Canary.Index.list_documents(source.id)
    assert length(docs) == 0 + 2 - 1
  end

  test "update_summary", %{source: source} do
    Canary.AI.Mock
    |> expect(:chat, 1, fn _, _ -> {:ok, "completion"} end)

    doc =
      Canary.Sources.Document
      |> Ash.create!(
        %{
          source_id: source.id,
          title: "hello",
          url: "/a",
          html: "<h1>hello</h1>"
        },
        action: :create
      )

    assert doc.summary == nil

    summary = %Canary.Sources.DocumentSummary{keywords: ["hello"]}
    updated = Canary.Sources.Document.update_summary!(doc, summary)
    assert updated.summary == summary
  end
end

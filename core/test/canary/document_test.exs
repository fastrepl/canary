defmodule Canary.Test.Document do
  use Canary.DataCase, async: false
  import Canary.AccountsFixtures

  setup do
    :ok = Canary.Typesense.ensure_collection()
    on_exit(fn -> Canary.Typesense.delete_collection() end)

    account = account_fixture()
    source = Canary.Sources.Source.create_web!(account, "https://example.com")

    %{source: source}
  end

  test "create", %{source: source} do
    {:ok, docs} = Canary.Typesense.search_documents(source.id, "hello")
    assert length(docs) == 0

    result =
      [
        %{source: source.id, title: "title1", url: "/a", content: "content1"},
        %{source: source.id, title: "title2", url: "/b", content: "content2"}
      ]
      |> Ash.bulk_create(Canary.Sources.Document, :create)

    assert result.status == :success
    assert Canary.Repo.all(Canary.Sources.Document) |> length() == 2

    {:ok, docs} = Canary.Typesense.search_documents(source.id, "tit")
    assert length(docs) == 2
  end

  test "destroy", %{source: source} do
    {:ok, docs} = Canary.Typesense.search_documents(source.id, "hello")
    assert length(docs) == 0

    result =
      [
        %{source: source.id, title: "title1", url: "/a", content: "content1"},
        %{source: source.id, title: "title2", url: "/b", content: "content2"},
        %{source: source.id, title: "title3", url: "/c", content: "content3"},
        %{source: source.id, title: "abcd", url: "/d", content: "content4"}
      ]
      |> Ash.bulk_create(Canary.Sources.Document, :create, return_records?: true)

    assert result.status == :success
    assert Canary.Repo.all(Canary.Sources.Document) |> length() == 4

    target = Enum.at(result.records, 0)

    {:ok, _} = Canary.Typesense.get_document(target.index_id)

    Canary.Sources.Document.destroy!(target)
    assert Canary.Repo.all(Canary.Sources.Document) |> length() == 3

    {:error, _} = Canary.Typesense.get_document(target.index_id)
  end
end

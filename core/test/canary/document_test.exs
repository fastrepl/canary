defmodule Canary.Test.Document do
  use Canary.DataCase, async: false
  import Canary.AccountsFixtures

  import Mox
  setup :verify_on_exit!

  setup do
    account = account_fixture()
    source = Canary.Sources.Source.create_web!(account, "https://example.com")

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
            source: source.id,
            title: "hello",
            url: "/a",
            content: "content"
          },
          %{
            source: source.id,
            title: "hello",
            url: "/b",
            content: "content"
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

    target = create_result.records |> Enum.at(1)
    delete_result = Ash.bulk_destroy([target], :destroy, %{}, return_errors?: true)
    assert delete_result.status == :success

    assert Canary.Repo.all(Canary.Sources.Document) |> length() == 2 - 1
    {:ok, docs} = Canary.Index.list_documents(source.id)
    assert length(docs) == 0 + 2 - 1
  end
end

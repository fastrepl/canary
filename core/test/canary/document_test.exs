defmodule Canary.Test.Document do
  use Canary.DataCase, async: false
  import Canary.AccountsFixtures

  setup do
    {:ok, _} = Canary.Index.create()
    account = account_fixture()
    source = Canary.Sources.Source.create_web!(account, "https://example.com")

    on_exit(fn -> Canary.Index.delete() end)

    %{source: source}
  end

  test "create", %{source: source} do
    {:ok, %{"hits" => hits}} = Canary.Index.Document.search(source.id, "hello")
    assert length(hits) == 0

    result =
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
            title: "hi",
            url: "/b",
            content: "content"
          }
        ],
        Canary.Sources.Document,
        :create,
        return_errors?: true
      )

    assert result.status == :success

    {:ok, %{"hits" => hits}} = Canary.Index.Document.search(source.id, "hello")
    assert length(hits) == 1
  end
end

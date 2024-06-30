defmodule Canary.SearchTest do
  use Canary.DataCase
  import Canary.AccountsFixtures
  require Ash.Query

  import Mox
  setup :verify_on_exit!

  test "search" do
    account = account_fixture()
    source = Canary.Sources.Source.create_web!(account, "example", "https://example.com")

    Canary.AI.Mock
    |> expect(:embedding, 1, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

    Canary.Sources.Document.ingest_text(source, "t")

    {:ok, chunks} = Canary.Sources.Chunk.search("t", Enum.to_list(1..384), 0)
    assert length(chunks) == 1

    chunks =
      Canary.Sources.Chunk
      |> Ash.Query.filter(document.source_id in ^[])
      |> Ash.read!()

    assert length(chunks) == 0

    chunks =
      Canary.Sources.Chunk
      |> Ash.Query.filter(document.source_id in ^[source.id])
      |> Ash.read!()

    assert length(chunks) == 1
  end
end

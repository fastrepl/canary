defmodule Canary.Test.Sources do
  use Canary.DataCase
  import Canary.AccountsFixtures
  require Ash.Query

  import Mox
  setup :verify_on_exit!

  alias Canary.Sources.Source
  alias Canary.Sources.Document
  alias Canary.Sources.Chunk

  setup do
    account = account_fixture()
    source = Source.create_web!(account, "https://example.com")

    %{account: account, source: source}
  end

  describe "document" do
    test "ingest", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 1, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      Document.ingest_text!(source, "url_1", "title_1", "t")

      assert Canary.Repo.all(Document) |> Enum.count() == 0 + 1
      assert Canary.Repo.all(Chunk) |> Enum.count() == 0 + 1
    end
  end

  describe "chunk" do
    test "hybrid_search", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 1, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      Document.ingest_text!(source, "url_1", "title_1", "t")

      {:ok, chunks} = Chunk.hybrid_search("t", Enum.to_list(1..384), 0)
      assert length(chunks) == 1
    end

    test "fts_search", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 3, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      {:ok, chunks} = Chunk.fts_search("k")
      assert length(chunks) == 0

      Document.ingest_text!(source, "url_1", "title_1", "ttt")
      Document.ingest_text!(source, "url_2", "title_2", "a bbb cbbb d")
      Document.ingest_text!(source, "url_3", "title_3", "bbb")

      {:ok, chunks} = Chunk.fts_search("bbb")
      assert length(chunks) == 2

      assert Enum.at(chunks, 0).content == "<mark>bbb</mark>"
      assert Enum.at(chunks, 1).content == "a <mark>bbb</mark> c<mark>bbb</mark> d"
    end
  end
end

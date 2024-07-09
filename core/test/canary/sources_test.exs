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
    source = Source.create!(account, :docusaurus, "https://example.com", "/docs")

    %{account: account, source: source}
  end

  describe "document" do
    test "ingest", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 1, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      doc = Document.ingest_text!(source, "/docs/intro.md", "Hello, world!")
      doc = doc |> Ash.load!(:url)
      assert doc.url == "https://example.com/docs/intro"

      assert Canary.Repo.all(Document) |> Enum.count() == 0 + 1
      assert Canary.Repo.all(Chunk) |> Enum.count() == 0 + 1
    end
  end

  describe "chunk" do
    test "hybrid_search", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 1, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      Document.ingest_text!(source, "/docs/intro.md", "t")

      {:ok, chunks} = Chunk.hybrid_search("t", Enum.to_list(1..384), 0)
      assert length(chunks) == 1
    end

    test "fts_search", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 3, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      Document.ingest_text!(source, "/docs/intro.md", "ttt")
      Document.ingest_text!(source, "/docs/intro.md", "a bbb bbb cddbb")
      Document.ingest_text!(source, "/docs/intro.md", "ccc")

      {:ok, [chunk]} = Chunk.fts_search("bbb")
      assert chunk.content == "a <mark>bbb</mark> <mark>bbb</mark> cdd<mark>bb</mark>"
    end
  end
end

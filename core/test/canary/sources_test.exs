defmodule Canary.SourcesTest do
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
    test "search", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 1, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      Document.ingest_text!(source, "/docs/intro.md", "ttt")

      {:ok, chunks} = Chunk.search("ttt", Enum.to_list(1..384), 0)
      assert length(chunks) == 1
    end
  end
end

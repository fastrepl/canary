defmodule Canary.SourcesTest do
  use Canary.DataCase
  import Canary.AccountsFixtures

  import Mox
  setup :verify_on_exit!

  setup do
    account = account_fixture()
    source = Canary.Sources.Source.create_web!(account, "example", "https://example.com")

    %{account: account, source: source}
  end

  describe "document" do
    test "ingest", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 1, fn _ -> {:ok, [Enum.to_list(1..384)]} end)

      doc = Canary.Sources.Document.ingest_text!(source, "Hello, world!")
      assert doc.content_hash == :crypto.hash(:sha256, "Hello, world!")

      chunks =
        doc
        |> Ash.load!(:chunks)
        |> Map.get(:chunks)

      assert length(chunks) == 1
    end
  end
end

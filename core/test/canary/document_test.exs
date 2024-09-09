defmodule Canary.Test.Document do
  use Canary.DataCase
  import Canary.AccountsFixtures

  describe "webpage" do
    test "create and find" do
      account = account_fixture()

      source =
        Canary.Sources.Source
        |> Ash.Changeset.new()
        |> Ash.Changeset.for_action(:create, %{
          account_id: account.id,
          name: "Docs",
          config: %Ash.Union{type: :webpage, value: %Canary.Sources.Webpage.Config{}}
        })
        |> Ash.create!()

      doc =
        Canary.Sources.Document
        |> Ash.Changeset.for_create(:create_webpage, %{
          source_id: source.id,
          url: "https://example.com/",
          html: "<body><h1>hello</h1></body>"
        })
        |> Ash.create!()

      assert doc.meta.type == :webpage
      assert doc.meta.value.url == "https://example.com"
      assert length(doc.chunks) == 1

      [found] = Canary.Sources.Document.find!(source.id, :webpage, :url, ["https://example.com"])
      assert found.id == doc.id
    end

    test "destroy" do
      account = account_fixture()

      source =
        Canary.Sources.Source
        |> Ash.Changeset.new()
        |> Ash.Changeset.for_action(:create, %{
          account_id: account.id,
          name: "Docs",
          config: %Ash.Union{type: :webpage, value: %Canary.Sources.Webpage.Config{}}
        })
        |> Ash.create!()

      Canary.Sources.Document
      |> Ash.Changeset.for_create(:create_webpage, %{
        source_id: source.id,
        url: "https://example.com/",
        html: "<body><h1>hello</h1></body>"
      })
      |> Ash.create!()

      docs = source |> Ash.load!(:documents) |> Map.get(:documents)
      assert length(docs) == 1
      Ash.bulk_destroy(docs, :destroy, %{}, return_errors?: true)

      docs = source |> Ash.load!(:documents) |> Map.get(:documents)
      assert length(docs) == 0
    end
  end
end

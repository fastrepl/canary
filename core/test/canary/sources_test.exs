defmodule Canary.SourcesTest do
  require Ash.Query
  use Canary.DataCase

  import Canary.AccountsFixtures

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  alias Canary.Sources.Document

  setup do
    account = account_fixture()

    source =
      Canary.Sources.Source
      |> Ash.Changeset.for_create(:create_web, %{
        account_id: account.id,
        web_base_url: "https://example.com"
      })
      |> Ash.create!()

    %{account: account, source: source}
  end

  describe "ingest" do
    test "single", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 3, fn _ -> {:ok, [[1, 2, 3]]} end)

      assert Canary.Repo.all(Document) |> Enum.count() == 0

      args_1 = %{content: "Hello, world!", source_id: source.id}
      args_2 = %{content: "hi, world!", source_id: source.id}

      Document
      |> Ash.Changeset.for_create(:ingest, args_1)
      |> Ash.create!()

      Document
      |> Ash.Changeset.for_create(:ingest, args_1)
      |> Ash.create!()

      assert Canary.Repo.all(Document) |> Enum.count() == 1

      Document
      |> Ash.Changeset.for_create(:ingest, args_2)
      |> Ash.create!()

      assert Canary.Repo.all(Document) |> Enum.count() == 2

      [src] = Canary.Repo.all(Canary.Sources.Source)
      src = src |> Ash.load!(:updated_at)
      IO.inspect(src)

      # destroy all documents, filter with source_id, and behind 1 day old compared to updated_at
      res =
        Canary.Sources.Document
        |> Ash.Query.filter(source_id == ^src.id)
        |> Ash.Query.filter(updated_at < ^DateTime.add(src.updated_at, -1, :day))
        |> Ash.bulk_destroy(:destroy, %{})

      IO.inspect(res)

      # q =
      #   Canary.Sources.Document
      #   |> Ash.Query.new()
      #   |> Ash.Query.filter(source_id == ^source.id)
      #   |> Ash.read!()

      # IO.inspect(q)

      # q =
      #   Canary.Sources.Document
      #   |> Ash.Query.aggregate(:last_updated_at, :max, :updated_at)

      # IO.inspect(q)
    end

    test "bulk create", %{source: source} do
      Canary.AI.Mock
      |> expect(:embedding, 2, fn _ -> {:ok, [[1, 2, 3]]} end)

      assert Canary.Repo.all(Document) |> Enum.count() == 0

      ["Hello, world!", "Hello, mars!"]
      |> Enum.map(fn content -> %{source_id: source.id, content: content} end)
      |> Ash.bulk_create!(Document, :ingest, return_records?: false)

      assert Canary.Repo.all(Document) |> Enum.count() == 2
    end
  end

  test "embedding only calculated by `after_action` hook when new content added",
       %{source: source} do
    Canary.AI.Mock
    |> expect(:embedding, 1, fn _ -> {:ok, [[1, 2, 3]]} end)
    |> expect(:embedding, 1, fn _ -> {:ok, [[4, 5, 6]]} end)

    args_1 = %{content: "Hello, world!", source_id: source.id}
    args_2 = %{content: "hi, world!", source_id: source.id}

    doc1 =
      Document
      |> Ash.Changeset.for_create(:ingest, args_1)
      |> Ash.create!()

    assert doc1.content_embedding == nil
    doc1 = doc1 |> Ash.load!(:content_embedding)

    assert doc1
           |> Map.get(:content_embedding)
           |> Ash.Vector.to_list() == [1, 2, 3]

    doc2 =
      Document
      |> Ash.Changeset.for_create(:ingest, args_1)
      |> Ash.create!()

    assert doc1.content == doc2.content
    assert doc1.content_embedding == doc2.content_embedding
    assert DateTime.before?(doc1.updated_at, doc2.updated_at)

    doc3 =
      Document
      |> Ash.Changeset.for_create(:ingest, args_2)
      |> Ash.create!()

    doc3 = doc3 |> Ash.load!(:content_embedding)

    assert doc2.content != doc3.content
    assert doc2.content_embedding != doc3.content_embedding
    assert DateTime.before?(doc2.updated_at, doc3.updated_at)

    source = source |> Ash.load!(:updated_at)
    assert DateTime.compare(source.updated_at, doc3.updated_at) == :eq
    assert DateTime.compare(source.updated_at, doc2.updated_at) != :eq
  end
end

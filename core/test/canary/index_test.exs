defmodule Canary.Test.Index do
  use ExUnit.Case, async: false

  setup do
    {:ok, _} = Canary.Index.create()
    on_exit(fn -> Canary.Index.delete() end)
  end

  test "insert and delete" do
    source_id = Ash.UUID.generate()

    {:ok, results} =
      Canary.Index.Document.batch_insert([
        %{
          source: source_id,
          title: "hello",
          content: "hello",
          tags: ["a", "b"]
        },
        %{
          source: source_id,
          title: "hello",
          tags: ["a", "c"],
          content: "hello"
        }
      ])

    assert results == [%{"id" => "0", "success" => true}, %{"id" => "1", "success" => true}]

    {:ok, %{"hits" => hits}} = Canary.Index.Document.search(source_id, "hello", ["c"])
    assert length(hits) == 1

    Canary.Index.Document.batch_delete([1])

    {:ok, %{"hits" => hits}} = Canary.Index.Document.search(source_id, "hello", ["c"])
    assert length(hits) == 0
  end

  test "insert and update" do
    source_id = Ash.UUID.generate()

    {:ok, _} =
      Canary.Index.Document.batch_insert([
        %{
          source: source_id,
          title: "hello",
          content: "hello",
          tags: ["a", "b"],
          meta: %{a: 1, b: 2}
        },
        %{
          source: source_id,
          title: "hello",
          content: "hello",
          tags: ["a", "c"],
          meta: %{a: 1, b: 2}
        }
      ])

    {:ok, %{"hits" => hits}} = Canary.Index.Document.search(source_id, "hello", ["c"])
    assert length(hits) == 1

    {:ok, _} = Canary.Index.Document.batch_update([%{id: "0", tags: ["c"]}])

    {:ok, %{"hits" => hits}} = Canary.Index.Document.search(source_id, "hello")
    assert length(hits) == 2
  end
end

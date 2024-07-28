defmodule Canary.Test.Index do
  use ExUnit.Case, async: false

  setup do
    {:ok, _} = Canary.Index.create()
    on_exit(fn -> Canary.Index.delete() end)
  end

  test "insert and delete" do
    {:ok, results} =
      Canary.Index.batch_insert([
        %{
          title: "hello",
          content: "hello",
          tags: ["a", "b"],
          meta: %{a: 1, b: 2}
        },
        %{
          title: "hello",
          content: "hello",
          tags: ["a", "c"],
          meta: %{a: 1, b: 2}
        }
      ])

    assert results == [%{"id" => "0", "success" => true}, %{"id" => "1", "success" => true}]

    {:ok, %{"hits" => hits}} = Canary.Index.search("hello", ["c"])
    assert length(hits) == 1

    Canary.Index.batch_delete([1])

    {:ok, %{"hits" => hits}} = Canary.Index.search("hello", ["c"])
    assert length(hits) == 0
  end

  test "insert and update" do
    {:ok, _} =
      Canary.Index.batch_insert([
        %{
          title: "hello",
          content: "hello",
          tags: ["a", "b"],
          meta: %{a: 1, b: 2}
        },
        %{
          title: "hello",
          content: "hello",
          tags: ["a", "c"],
          meta: %{a: 1, b: 2}
        }
      ])

    {:ok, %{"hits" => hits}} = Canary.Index.search("hello", ["c"])
    assert length(hits) == 1

    {:ok, _} = Canary.Index.batch_update([%{id: 0, tags: ["c"]}])

    {:ok, %{"hits" => hits}} = Canary.Index.search("hello")
    assert length(hits) == 2
  end
end

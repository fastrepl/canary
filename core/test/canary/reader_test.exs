defmodule Canary.Test.Reader do
  use ExUnit.Case, async: false

  describe "default" do
    test "simple" do
      {:ok, md} =
        "test/canary/fixtures/simple.html" |> File.read!() |> Canary.Reader.Default.html_to_md()

      assert md ==
               """
               Floki
               Enables search using CSS selectors
               [Github page](https://github.com/philss/floki)
               philss
               [Hex package](https://hex.pm/packages/floki)
               """
               |> String.trim()
    end

    test "litellm" do
      {:ok, md} =
        "test/canary/fixtures/litellm.html" |> File.read!() |> Canary.Reader.Default.html_to_md()

      assert String.length(md) > 1000
    end

    test "astro" do
      {:ok, md} =
        "test/canary/fixtures/astro.html" |> File.read!() |> Canary.Reader.Default.html_to_md()

      assert String.length(md) > 1000
    end
  end
end

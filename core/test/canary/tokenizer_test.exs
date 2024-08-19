defmodule Canary.Test.Tokenizer do
  use ExUnit.Case, async: true
  alias Canary.Tokenizer

  describe "count_tokens/1" do
    test "llama" do
      num = Tokenizer.load(:llama) |> Tokenizer.count_tokens("Hello world")
      assert num == 3
    end
  end
end

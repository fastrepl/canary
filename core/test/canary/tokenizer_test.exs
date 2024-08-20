defmodule Canary.Test.Tokenizer do
  use ExUnit.Case, async: true
  alias Canary.Tokenizer

  describe "count_tokens/1" do
    test "llama" do
      tokenizer = Tokenizer.load!(:llama_2)
      num = "Hello world" |> Tokenizer.count_tokens(tokenizer)
      assert num == 3
    end
  end
end

defmodule Canary.Test.Sugestor do
  use ExUnit.Case, async: true

  alias Canary.Query.Sugestor

  test "default" do
    cases = [
      {"", []},
      {"docker", ["Can you tell me about 'Docker'?"]},
      {"can you tell me about docker?", ["Can you tell me about docker?"]}
    ]

    for {query, suggested} <- cases do
      assert Sugestor.run!(query) == suggested
    end
  end
end

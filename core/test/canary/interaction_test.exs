defmodule Canary.Test.Interaction do
  use ExUnit.Case, async: false

  import Mox
  setup :verify_on_exit!

  alias Canary.Interactions.Processor

  describe "processor" do
    setup do
      start_supervised!({
        Processor,
        name: Processor.Test
      })

      :ok
    end

    test "it works" do
    end
  end
end

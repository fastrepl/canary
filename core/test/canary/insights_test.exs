defmodule Canary.Test.Insights do
  use ExUnit.Case, async: false

  import Mox
  setup :verify_on_exit!

  alias Canary.Interactions.AnalyticsExporter

  describe "AnalyticsExporter" do
    setup do
      start_supervised!({
        AnalyticsExporter,
        name: AnalyticsExporter.Test
      })

      :ok
    end

    test "it works" do
    end
  end
end

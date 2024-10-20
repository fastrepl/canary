defmodule Canary.Test.Insights do
  use ExUnit.Case, async: false

  import Mox
  setup :verify_on_exit!

  alias Canary.Interactions.QueryExporter
  alias Canary.Interactions.UsageExporter

  describe "QueryExporter" do
    setup do
      start_supervised!({
        QueryExporter,
        name: QueryExporter.Test
      })

      :ok
    end

    test "it works" do
    end
  end

  describe "UsageExporter" do
    setup do
      start_supervised!({
        UsageExporter,
        name: UsageExporter.Test
      })

      :ok
    end

    test "it works" do
    end
  end
end

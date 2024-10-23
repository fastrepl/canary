defmodule Canary.Test.Interactions do
  use Canary.DataCase, async: false

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
        name: UsageExporter.Test, opts: %{export_interval_ms: 100}
      })

      :ok
    end

    test "it works" do
    end
  end
end

defmodule Canary.Test.Interactions do
  use Canary.DataCase, async: false
  import Canary.AccountsFixtures

  import Mox
  setup :verify_on_exit!
  setup :set_mox_from_context

  alias Canary.Interactions.QueryExporter
  alias Canary.Interactions.UsageExporter

  describe "UsageExporter" do
    setup do
      opts = %{export_interval_ms: 500}
      start_supervised!({UsageExporter, name: UsageExporter.Test, opts: opts})
      opts
    end

    test "it works", %{export_interval_ms: export_interval_ms} do
      Canary.Index.Trieve.Mock
      |> expect(:client, 1, fn _project -> :ok end)
      |> expect(:create_dataset, 1, fn _client, _data -> :ok end)

      Canary.Analytics.Mock
      |> expect(:ingest, 1, fn :usage, _items -> :ok end)

      account_1 = account_fixture()
      project_1 = Canary.Accounts.Project.create!(account_1.id, "project_1", authorize?: false)

      :ok =
        UsageExporter.Test
        |> GenServer.cast({:search, %{project_id: project_1.id, query: "query"}})

      Process.sleep(export_interval_ms + 100)
      :ok = GenServer.stop(UsageExporter.Test)
    end
  end

  describe "QueryExporter" do
    setup do
      # Increased export_delay_ms
      opts = %{export_interval_ms: 500, export_delay_ms: 200}
      start_supervised!({QueryExporter, name: QueryExporter.Test, opts: opts})
      opts
    end

    test "it works", %{export_interval_ms: export_interval_ms} do
      Canary.Index.Trieve.Mock
      |> expect(:client, 1, fn _project -> :ok end)
      |> expect(:create_dataset, 1, fn _client, _data -> :ok end)

      Canary.Analytics.Mock
      |> expect(:ingest, 1, fn :search, items ->
        assert length(items) == 1
      end)

      account_1 = account_fixture()
      project_1 = Canary.Accounts.Project.create!(account_1.id, "project_1", authorize?: false)

      session_id = Ecto.UUID.generate()

      :ok =
        QueryExporter.Test
        |> GenServer.cast(
          {:search, %{session_id: session_id, project_id: project_1.id, query: "que"}}
        )

      Process.sleep(50)

      :ok =
        QueryExporter.Test
        |> GenServer.cast(
          {:search, %{session_id: session_id, project_id: project_1.id, query: "quer"}}
        )

      Process.sleep(50)

      :ok =
        QueryExporter.Test
        |> GenServer.cast(
          {:search, %{session_id: session_id, project_id: project_1.id, query: "query"}}
        )

      Process.sleep(export_interval_ms + 100)
      :ok = GenServer.stop(QueryExporter.Test)
    end
  end
end

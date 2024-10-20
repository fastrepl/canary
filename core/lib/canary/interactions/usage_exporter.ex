defmodule Canary.Interactions.UsageExporter do
  @moduledoc """
  Usage:

  GenServer.cast(Canary.Interactions.UsageExporter, {:search, %{project_public_key: "..."}})
  """

  use GenServer
  require Ash.Query

  @export_interval_ms 15_000
  @initial_state %{search: %{}, ask: %{}}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(_args) do
    Process.flag(:trap_exit, true)
    schedule_batch()
    {:ok, @initial_state}
  end

  @impl true
  def handle_cast({:search, %{project_public_key: key}}, state) do
    state = state |> update_in([:search, Access.key(key, 0)], &(&1 + 1))
    {:noreply, state}
  end

  def handle_cast({:ask, %{project_public_key: key}}, state) do
    state = state |> update_in([:ask, Access.key(key, 0)], &(&1 + 1))
    {:noreply, state}
  end

  def handle_cast({:search, _}, state), do: {:noreply, state}
  def handle_cast({:ask, _}, state), do: {:noreply, state}

  @impl true
  def handle_info(:handle_batch, state) do
    process(state)
    schedule_batch()
    {:noreply, @initial_state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state), do: {:noreply, state}
  def handle_info({_ref, _ret}, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, state) do
    process(state)
    :ok
  end

  defp schedule_batch, do: Process.send_after(self(), :handle_batch, @export_interval_ms)

  defp process(%{search: search, ask: ask}) do
    Task.Supervisor.async_nolink(Canary.TaskSupervisor, fn ->
      keys = Map.keys(search) ++ Map.keys(ask)

      accounts =
        Canary.Accounts.Account
        |> Ash.Query.filter(projects.public_key in ^keys)
        |> Ash.Query.select([:id])
        |> Ash.read!(load: [:projects])

      search_rows =
        search
        |> Enum.map(fn {key, count} ->
          account =
            accounts
            |> Enum.find(fn account -> Enum.any?(account.projects, &(&1.public_key == key)) end)

          project = Enum.find(account.projects, &(&1.public_key == key))
          %{type: :search, count: count, account_id: account.id, project_id: project.id}
        end)

      ask_rows =
        ask
        |> Enum.map(fn {key, count} ->
          account =
            accounts
            |> Enum.find(fn account -> Enum.any?(account.projects, &(&1.public_key == key)) end)

          project = Enum.find(account.projects, &(&1.public_key == key))
          %{type: :ask, count: count, account_id: account.id, project_id: project.id}
        end)

      (search_rows ++ ask_rows)
      |> Enum.map(&Map.put(&1, :timestamp, DateTime.utc_now()))
      |> then(&Canary.Analytics.ingest(:usage, &1))
    end)
  end
end

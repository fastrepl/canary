defmodule Canary.Interactions.UsageExporter do
  @moduledoc """
  Usage:

  GenServer.cast(Canary.Interactions.UsageExporter, {:search, %{project_id: "..."}})
  """

  use GenServer
  require Ash.Query
  require Logger

  @initial_data %{search: %{}, ask: %{}}
  @default_opts %{export_interval_ms: 15_000}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:opts] || %{}, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    state = %{data: @initial_data, opts: Map.merge(@default_opts, opts)}
    schedule_batch(state)

    {:ok, state}
  end

  @impl true
  def handle_cast({:search, %{project_id: key}}, state) do
    {:noreply, update_in(state, [:data, :search, Access.key(key, 0)], &(&1 + 1))}
  end

  def handle_cast({:ask, %{project_id: key}}, state) do
    {:noreply, update_in(state, [:data, :ask, Access.key(key, 0)], &(&1 + 1))}
  end

  def handle_cast({:search, _}, state), do: {:noreply, state}
  def handle_cast({:ask, _}, state), do: {:noreply, state}

  @impl true
  def handle_info(:handle_batch, state) do
    process(state)
    schedule_batch(state)
    {:noreply, Map.merge(state, %{data: @initial_data})}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state), do: {:noreply, state}
  def handle_info({_ref, :ok}, state), do: {:noreply, state}

  def handle_info({_ref, {:error, error}}, state) do
    Logger.error("failed to export usage: #{error}")
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    process(state)
    :ok
  end

  defp schedule_batch(%{opts: %{export_interval_ms: t}}) do
    Process.send_after(self(), :handle_batch, t)
  end

  defp process(%{data: %{search: search, ask: ask}}) do
    Task.Supervisor.async_nolink(Canary.TaskSupervisor, fn ->
      ids = Map.keys(search) ++ Map.keys(ask)

      accounts =
        Canary.Accounts.Account
        |> Ash.Query.filter(projects.id in ^ids)
        |> Ash.Query.select([:id])
        |> Ash.read!(load: [:projects])

      rows =
        Enum.map(search, fn pair -> {:search, pair} end) ++
          Enum.map(ask, fn pair -> {:ask, pair} end)

      rows =
        rows
        |> Enum.map(fn {type, {project_id, count}} ->
          account =
            Enum.find(accounts, fn account ->
              Enum.any?(account.projects, &(&1.id == project_id))
            end)

          %{type: type, count: count, account_id: account.id, project_id: project_id}
        end)
        |> Enum.map(&Map.put(&1, :timestamp, DateTime.utc_now()))

      :ok = Canary.Analytics.ingest(:usage, rows)
    end)
  end
end

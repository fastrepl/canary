defmodule Canary.Interactions.QueryExporter do
  @moduledoc """
  Usage:

  GenServer.cast(Canary.Interactions.QueryExporter, {:search, %{session_id: "...", project_id: "...", query: "..."}})
  """

  use GenServer
  require Logger

  @initial_data %{search: %{}}
  @default_opts %{export_interval_ms: 15_000, export_delay_ms: 3_000}

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
  def handle_cast({:search, payload}, state) do
    session_id =
      case Map.get(payload, :session_id) do
        nil -> Ash.UUID.generate()
        "" -> Ash.UUID.generate()
        id -> id
      end

    item = payload |> Map.put(:timestamp, DateTime.utc_now())

    {:noreply, state |> update_in([:data, :search, Access.key(session_id, [])], &[item | &1])}
  end

  @impl true
  def handle_info(:handle_batch, %{opts: %{export_delay_ms: _export_delay_ms}} = state) do
    process(state)
    schedule_batch(state)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state), do: {:noreply, state}
  def handle_info({_ref, :ok}, state), do: {:noreply, state}

  def handle_info({_ref, {:error, error}}, state) do
    Logger.error("failed to export query: #{error}")
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

  defp process(%{data: %{search: search}}) when map_size(search) == 0, do: :ok

  defp process(%{data: %{search: search}} = state) do
    {keep, send} =
      search
      |> Enum.reduce({%{}, []}, fn {session_id, items}, {keep_acc, send_acc} ->
        {items_to_keep, items_to_send} = dedupe(items)
        {Map.put(keep_acc, session_id, items_to_keep), send_acc ++ items_to_send}
      end)

    Task.Supervisor.async_nolink(Canary.TaskSupervisor, fn ->
      Canary.Analytics.ingest(:search, send)
    end)

    {:noreply, state |> put_in([:data, :search], keep)}
  end

  defp dedupe(items) do
    {[], items}
  end
end

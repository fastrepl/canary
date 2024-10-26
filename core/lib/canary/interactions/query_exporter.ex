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
      case payload
           |> Map.get(:session_id)
           |> Ecto.UUID.cast() do
        {:ok, uuid} -> uuid
        :error -> Ecto.UUID.generate()
      end

    item = payload |> Map.put(:timestamp, DateTime.utc_now())

    {:noreply, state |> update_in([:data, :search, Access.key(session_id, [])], &[item | &1])}
  end

  @impl true
  def handle_info(:handle_batch, %{opts: %{export_delay_ms: _export_delay_ms}} = state) do
    next_state = process(state)
    schedule_batch(next_state)
    {:noreply, next_state}
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

  defp process(%{data: %{search: search}} = state) when map_size(search) == 0, do: state

  defp process(%{data: %{search: search}, opts: %{export_delay_ms: export_delay_ms}} = state) do
    now = DateTime.utc_now()

    {keep, send} =
      search
      |> Enum.reduce({%{}, []}, fn {session_id, items}, {keep_acc, send_acc} ->
        {items_to_keep, items_to_send} =
          items
          |> Enum.map(&Map.put(&1, :session_id, session_id))
          |> dedupe(now, export_delay_ms)

        {Map.put(keep_acc, session_id, items_to_keep), send_acc ++ items_to_send}
      end)

    Task.Supervisor.async_nolink(Canary.TaskSupervisor, fn ->
      :ok = Canary.Analytics.ingest(:search, send)
    end)

    put_in(state, [:data, :search], keep)
  end

  defp dedupe(items, now, export_delay_ms) do
    items = Enum.sort_by(items, & &1.timestamp, DateTime)
    dedupe_items(items, now, export_delay_ms, [], [])
  end

  defp dedupe_items([], _now, _export_delay_ms, items_to_keep, items_to_send) do
    {items_to_keep, items_to_send}
  end

  defp dedupe_items([item], now, export_delay_ms, items_to_keep, items_to_send) do
    time_since_item = DateTime.diff(now, item.timestamp, :millisecond)

    if time_since_item >= export_delay_ms do
      dedupe_items([], now, export_delay_ms, items_to_keep, [item | items_to_send])
    else
      dedupe_items([], now, export_delay_ms, [item | items_to_keep], items_to_send)
    end
  end

  defp dedupe_items([item1, item2 | rest], now, export_delay_ms, items_to_keep, items_to_send) do
    time_diff = DateTime.diff(item2.timestamp, item1.timestamp, :millisecond)
    is_prefix = String.starts_with?(item2.query, item1.query)
    time_since_item1 = DateTime.diff(now, item1.timestamp, :millisecond)

    cond do
      is_prefix and time_diff <= export_delay_ms ->
        dedupe_items([item2 | rest], now, export_delay_ms, items_to_keep, items_to_send)

      time_since_item1 >= export_delay_ms ->
        dedupe_items([item2 | rest], now, export_delay_ms, items_to_keep, [item1 | items_to_send])

      true ->
        dedupe_items([item2 | rest], now, export_delay_ms, [item1 | items_to_keep], items_to_send)
    end
  end
end

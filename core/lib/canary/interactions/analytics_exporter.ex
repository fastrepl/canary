defmodule Canary.Interactions.AnalyticsExporter do
  @moduledoc """
  Usage:

  GenServer.cast(Canary.Interactions.AnalyticsExporter, {:search, %{session_id: "...", project_id: "...", query: "..."}})
  """

  use GenServer

  @export_interval_ms 10_000
  @export_delay_ms 3_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(_args) do
    Process.flag(:trap_exit, true)
    schedule_batch()
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:search, %{project_id: _} = payload}, state) do
    session_id =
      case Map.get(payload, :session_id) do
        nil -> Ash.UUID.generate()
        "" -> Ash.UUID.generate()
        id -> id
      end

    item =
      payload
      |> Map.put(:session_id, session_id)
      |> Map.put(:timestamp, DateTime.utc_now())

    {:noreply, state |> Map.update(session_id, [item], &[item | &1])}
  end

  @impl true
  def handle_cast({:search, _}, state), do: {:noreply, state}

  @impl true
  def handle_info(:handle_batch, state) do
    now = DateTime.utc_now()

    {updated_state, items_to_process} =
      state
      |> Enum.reduce(
        {%{}, []},
        fn {session_id, items}, {updated_state_acc, items_to_process_acc} ->
          {to_process, to_keep} =
            items
            |> Enum.split_with(fn item ->
              DateTime.diff(now, item.timestamp, :millisecond) > @export_delay_ms
            end)

          {
            updated_state_acc |> Map.put(session_id, to_keep),
            items_to_process_acc ++ deduplicate(to_process)
          }
        end
      )

    process(items_to_process)
    schedule_batch()
    {:noreply, updated_state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state), do: {:noreply, state}
  def handle_info({_ref, _ret}, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, state) do
    state
    |> Enum.flat_map(fn {_session_id, items} -> items end)
    |> process()

    :ok
  end

  defp schedule_batch do
    Process.send_after(self(), :handle_batch, @export_interval_ms)
  end

  defp process([]), do: :ok

  defp process(items) do
    Task.Supervisor.async_nolink(Canary.TaskSupervisor, fn ->
      Canary.Analytics.ingest("search", items)
    end)
  end

  def deduplicate(items) do
    items
    |> Enum.sort_by(& &1.timestamp, &(DateTime.compare(&1, &2) != :gt))
    |> Enum.reduce({[], nil}, fn item, {acc, last_query} ->
      if last_query != nil and
           (String.starts_with?(item.query, last_query) or
              String.ends_with?(item.query, last_query)) do
        [_ | items] = acc
        {[item | items], item.query}
      else
        {[item | acc], item.query}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end
end

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

      billings =
        Canary.Accounts.Billing
        |> Ash.Query.filter(account.projects.public_key in ^keys)
        |> Ash.Query.select([:id, :account_id])
        |> Ash.read!(load: [account: [:projects]])

      search
      |> Enum.each(fn {key, count} ->
        billing =
          billings
          |> Enum.find(
            &Enum.any?(&1.account.projects, fn project -> project.public_key == key end)
          )

        Canary.Accounts.Billing.increment_search!(billing.id, count)
      end)

      ask
      |> Enum.each(fn {key, count} ->
        billing =
          billings
          |> Enum.find(
            &Enum.any?(&1.account.projects, fn project -> project.public_key == key end)
          )

        Canary.Accounts.Billing.increment_search!(billing.id, count)
      end)
    end)
  end
end

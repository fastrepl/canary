defmodule Canary.Sessions.Session do
  use GenServer

  def start_link(%{id: session_id} = args) do
    GenServer.start_link(__MODULE__, args, name: via_registry(session_id))
  end

  @impl true
  def init(args) do
    Process.flag(:trap_exit, true)

    timeout = Map.get(args, :timeout, 1000 * 60 * 3)

    state =
      Map.new()
      |> Map.put(:id, args.id)
      |> Map.put(:timeout, timeout)
      |> Map.put(:history, [])

    {:ok, state, timeout}
  end

  @impl true
  def handle_call({:submit, :website, %{query: query}}, {from, _}, state) do
    state =
      state
      |> Map.update!(:history, &[%{type: :user, content: query} | &1])

    handle_message = fn content ->
      send(self(), {:update, :history, content})
      send(from, {:complete, %{id: state.id, done: true}})
    end

    handle_message_delta = fn content ->
      send(from, {:progress, %{id: state.id, content: content}})
    end

    Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
      Canary.Sessions.Responder.call(%{
        history: state.history,
        handle_message: handle_message,
        handle_message_delta: handle_message_delta
      })
    end)

    {:reply, :ok, state, state.timeout}
  end

  @impl true
  def handle_info({:update, :history, content}, state) do
    state =
      state
      |> Map.update!(:history, &[%{type: :ai, content: content} | &1])

    {:noreply, state, state.timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :timeout, state}
  end

  @impl true
  def terminate(_reason, state) do
    if state[:id] do
      Registry.unregister(Canary.Sessions.registry(), state.id)
    end

    :ok
  end

  defp via_registry(session_id) do
    {:via, Registry, {Canary.Sessions.registry(), session_id}}
  end
end

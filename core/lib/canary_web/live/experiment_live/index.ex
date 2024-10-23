defmodule CanaryWeb.ExperimentLive.Index do
  use CanaryWeb, :live_view
  alias Phoenix.LiveView.AsyncResult

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2>Experiment</h2>

      <div :if={@search_result.loading}>loading...</div>
      <div :if={!@search_result.loading && @search_result.result}>
        <div :for={result <- @search_result.result}>
          <pre><%= Jason.encode!(result) %></pre>
        </div>
      </div>

      <form phx-submit="submit" class="flex flex-col gap-2 items-center">
        <.input type="text" autocomplete="off" name="query" value="" />
        <.button type="submit" is_primary>Submit</.button>
      </form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:search_result, %AsyncResult{})

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"query" => query}, socket) do
    client = treive_client(socket)

    socket =
      socket
      |> cancel_async(:search_task)
      |> start_async(:search_task, fn -> Canary.Index.Trieve.search(client, query) end)

    {:noreply, socket}
  end

  @impl true
  def handle_async(:search_task, {:ok, {:ok, result}}, socket) do
    socket =
      socket
      |> assign(:search_result, AsyncResult.ok(%AsyncResult{}, result))

    {:noreply, socket}
  end

  def handle_async(:search_task, {:ok, {:error, error}}, socket) do
    socket =
      socket
      |> assign(:search_result, AsyncResult.failed(%AsyncResult{}, error))

    {:noreply, socket}
  end

  def handle_async(:search_task, {:exit, reason}, socket) do
    socket =
      socket
      |> put_flash(:error, "search_task failed: #{inspect(reason)}")
      |> assign(:search_result, %AsyncResult{})

    {:noreply, socket}
  end

  defp treive_client(socket) do
    socket.assigns.current_project
    |> Canary.Index.Trieve.client()
  end

  def get_chunks(socket, group_tracking_ids) do
    client = treive_client(socket)

    group_tracking_ids
    |> Task.async_stream(
      fn id ->
        case Canary.Index.Trieve.get_chunks(client, id) do
          {:ok, chunks} -> {:ok, chunks}
          {:error, error} -> {:error, error}
        end
      end,
      ordered: false,
      timeout: 3_000,
      max_concurrency: 5
    )
  end
end

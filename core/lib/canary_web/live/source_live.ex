defmodule CanaryWeb.SourceLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><.link navigate={~p"/sources"}>Sources</.link></li>
          <li><a><%= @source.name %></a></li>
        </ul>
      </div>

      <button class="btn btn-sm btn-neutral ml-auto" phx-click="delete">
        Delete
      </button>
    </.content_header>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    source = Canary.Sources.Source |> Ash.get!(id)

    socket =
      socket
      |> assign(source: source)

    {:ok, socket}
  end

  def handle_event("delete", _, socket) do
    socket.assigns.source |> Ash.destroy!()
    {:noreply, socket |> push_navigate(to: ~p"/sources")}
  end
end

defmodule CanaryWeb.ClientLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><.link navigate={~p"/clients"}>Clients</.link></li>
          <li><a><%= @client.name %></a></li>
        </ul>
      </div>
    </.content_header>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    client = Canary.Clients.Client |> Ash.get!(id)

    socket =
      socket
      |> assign(client: client)

    {:ok, socket}
  end
end

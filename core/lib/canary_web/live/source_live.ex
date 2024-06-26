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
end

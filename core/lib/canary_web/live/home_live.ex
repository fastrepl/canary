defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs font-semibold text-md flex flex-row items-center justify-between">
        <ul>
          <li><a>Home</a></li>
        </ul>
      </div>
    </.content_header>
    """
  end

  def mount(_params, _session, socket) do
    sources = Canary.Sources.Source |> Ash.read!()
    {:ok, socket |> assign(sources: sources)}
  end

  def handle_event("1", _, socket) do
    {:noreply, socket}
  end
end

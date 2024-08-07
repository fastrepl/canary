defmodule CanaryWeb.EditorHomeLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><a>Editor</a></li>
        </ul>
      </div>
      <button class="btn btn-neutral" phx-click="new">
        New
      </button>
    </.content_header>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("new", _, socket) do
    id = Ash.UUID.generate()
    {:noreply, socket |> push_navigate(to: ~p"/editor/#{id}")}
  end
end

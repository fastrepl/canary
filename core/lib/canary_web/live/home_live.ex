defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><a>Home</a></li>
        </ul>
      </div>
    </.content_header>
    """
  end

  def mount(_params, _session, socket) do
    if socket.assigns.current_account do
      account = socket.assigns.current_account |> Ash.load!([:sources, :clients])
      {:ok, socket |> assign(current_account: account)}
    else
      {:ok, socket |> redirect(to: ~p"/onboarding")}
    end
  end

  def handle_event("1", _, socket) do
    {:noreply, socket}
  end
end

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
    account = socket.assigns.current_account |> Ash.load!([:sources, :clients])

    if length(account.sources) == 0 or length(account.clients) == 0 do
      {:ok, socket |> redirect(to: ~p"/onboarding")}
    else
      {:ok, socket |> assign(current_account: account)}
    end

    {:ok, socket}
  end

  def handle_event("1", _, socket) do
    {:noreply, socket}
  end
end

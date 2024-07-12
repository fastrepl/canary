defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="hero bg-base-200 min-h-screen">
      <div class="hero-content text-center">
        <div class="max-w-md">
          <h1 class="text-5xl font-bold">Welcome to Canary</h1>
          <div class="py-8">
            <p>Canary works in three steps:</p>
          </div>

          <button class="btn btn-neutral">Get Started</button>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:sources, :clients])
    {:ok, socket |> assign(current_account: account)}
  end

  def handle_event("1", _, socket) do
    {:noreply, socket}
  end
end

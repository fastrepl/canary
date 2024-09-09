defmodule CanaryWeb.DemoLive.Fallback do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      fallback
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    {:ok, socket}
  end
end

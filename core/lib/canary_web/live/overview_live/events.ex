defmodule CanaryWeb.OverviewLive.Events do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2>Events</h2>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end
end

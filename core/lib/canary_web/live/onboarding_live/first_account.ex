defmodule CanaryWeb.OnboardingLive.FirstAccount do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2>First Account</h2>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket}
  end
end

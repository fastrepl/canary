defmodule CanaryWeb.OverviewLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2>Overview</h2>

      <.live_component
        id="overview-volume"
        module={CanaryWeb.OverviewLive.Volume}
        current_project={@current_project}
      />

      <.live_component
        id="overview-events"
        module={CanaryWeb.OverviewLive.Events}
        current_project={@current_project}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

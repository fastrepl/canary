defmodule CanaryWeb.PlaygroundLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        id="playground-search"
        module={CanaryWeb.PlaygroundLive.Search}
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

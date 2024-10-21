defmodule CanaryWeb.OnboardingLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      onboarding
      <.live_component
        id="code-example"
        module={CanaryWeb.OnboardingLive.CodeExample}
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

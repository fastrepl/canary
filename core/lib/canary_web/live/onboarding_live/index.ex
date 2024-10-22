defmodule CanaryWeb.OnboardingLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(%{invite?: true} = assigns) do
    ~H"""
    <div>
      <.live_component
        id="onboarding-handle-invite"
        module={CanaryWeb.OnboardingLive.HandleInvite}
        current_user={@current_user}
      />
    </div>
    """
  end

  def render(%{current_account: nil} = assigns) do
    ~H"""
    <div>
      <.live_component
        id="onboarding-first-account"
        module={CanaryWeb.OnboardingLive.FirstAccount}
        current_project={@current_project}
      />
    </div>
    """
  end

  def render(%{current_project: nil} = assigns) do
    ~H"""
    <div>
      <.live_component
        id="onboarding-first-project"
        module={CanaryWeb.OnboardingLive.FirstProject}
        current_project={@current_project}
      />
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        id="onboarding-first-source"
        module={CanaryWeb.OnboardingLive.FirstSource}
        current_project={@current_project}
      />
      <.live_component
        id="onboarding-first-search"
        module={CanaryWeb.OnboardingLive.FirstSearch}
        current_project={@current_project}
      />
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, socket |> assign(:invite?, params["invite"] == "true")}
  end
end

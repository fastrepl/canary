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
        view_pid={self()}
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
        current_user={@current_user}
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
        current_account={@current_account}
      />
    </div>
    """
  end

  def render(%{num_sources: 0} = assigns) do
    ~H"""
    <div>
      <.live_component
        id="onboarding-first-source"
        module={CanaryWeb.OnboardingLive.FirstSource}
        current_project={@current_project}
      />
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
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
    num_sources =
      if is_nil(socket.assigns[:current_project]) do
        0
      else
        project = socket.assigns[:current_project]
        project |> Ash.load!(:num_sources) |> Map.get(:num_sources)
      end

    socket =
      socket
      |> assign(:invite?, params["invite"] == "true")
      |> assign(:num_sources, num_sources)

    {:ok, socket}
  end

  @impl true
  def handle_info(:no_invites, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/")}
  end
end

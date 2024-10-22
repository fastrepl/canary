defmodule CanaryWeb.OnboardingLive.HandleInvite do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-gray-200 py-4 px-6 rounded-md">
      <h2>You have an invite!</h2>
      <pre><%= Jason.encode!(@invites) %></pre>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    invites =
      Canary.Accounts.Invite
      |> Ash.Query.for_read(:not_expired, %{}, actor: assigns.current_user)
      |> Ash.read!()

    socket =
      socket
      |> assign(assigns)
      |> assign(:invites, invites)

    {:ok, socket}
  end
end

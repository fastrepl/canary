defmodule CanaryWeb.BillingLive.Index do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>Billing</Primer.subhead>
      <p class="-mt-2 mb-4">
        All information displayed here is for the current organization only.
      </p>

      <.live_component
        id="billing-stats"
        module={CanaryWeb.BillingLive.Stats}
        current_account={@current_account}
      />

      <.live_component
        id="billing-plans"
        module={CanaryWeb.BillingLive.Plans}
        current_account={@current_account}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!(billing: [:membership])
    socket = socket |> assign(:current_account, account)
    {:ok, socket}
  end
end

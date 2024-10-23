defmodule CanaryWeb.BillingLive.Index do
  use CanaryWeb, :live_view
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="border-b mb-4">
        <h2>Billing</h2>
        <p>
          All information displayed here is for the current organization only.
        </p>
      </div>

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

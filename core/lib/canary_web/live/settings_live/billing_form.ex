defmodule CanaryWeb.SettingsLive.BillingForm do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer
  alias Canary.Accounts.Billing

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>Billing</Primer.subhead>
      <div class="flex flex-col gap-2 my-4">
        <Primer.text_input disabled value={@plan} form_control={%{label: "Current plan"}} />
        <%= render_billing_info(assigns) %>
      </div>
      <div class="flex flex-row gap-2 mt-4 justify-end">
        <%= render_action_button(assigns) %>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    stripe_portal_url =
      Application.get_env(:canary, :stripe)
      |> Keyword.fetch!(:customer_portal_url)

    billing = assigns.current_account.billing

    socket =
      socket
      |> assign(assigns)
      |> assign_billing_details(billing)
      |> assign(:stripe_portal_url, stripe_portal_url)

    {:ok, socket}
  end

  @impl true
  def handle_event("checkout", _, %{assigns: %{current_account: current_account}} = socket) do
    if current_account.billing.stripe_customer == nil do
      params = %{metadata: %{"account_id" => current_account.id}}

      with {:ok, customer} <- Stripe.Customer.create(params),
           {:ok, _} <- Billing.update_stripe_customer(current_account.billing, customer) do
        {:noreply, socket |> redirect(to: ~p"/checkout")}
      else
        {:error, error} ->
          {:noreply, socket |> put_flash(:error, error)}
      end
    else
      {:noreply, socket |> redirect(to: ~p"/checkout")}
    end
  end

  defp render_billing_info(assigns) do
    ~H"""
    <div class="flex flex-col gap-2 mt-2">
      <div>
        <span class="font-semibold">Status: </span>
        <span><%= @status %></span>
      </div>
      <div>
        <span class="font-semibold">Current period end: </span>
        <span><%= @current_period_end %></span>
      </div>
      <div>
        <span class="font-semibold">Will cancel at period end: </span>
        <span><%= @cancel_at_period_end %></span>
      </div>
      <div>
        <span class="font-semibold">Canceled at: </span>
        <span><%= @canceled_at %></span>
      </div>
    </div>
    """
  end

  defp render_action_button(%{current_account: %{billing: %{stripe_subscription: nil}}} = assigns) do
    ~H"""
    <Primer.button type="button" phx-click="checkout" phx-target={@myself} is_primary>
      Upgrade
    </Primer.button>
    """
  end

  defp render_action_button(assigns) do
    ~H"""
    <Primer.button href={@stripe_portal_url}>
      Manage
    </Primer.button>
    """
  end

  defp assign_billing_details(socket, billing) do
    subscription = billing.stripe_subscription

    socket
    |> assign(:plan, subscription_plan(subscription))
    |> assign(:status, subscription_status(subscription))
    |> assign(:cancel_at_period_end, subscription_cancel_at_period_end(subscription))
    |> assign(:canceled_at, format_date(subscription["canceled_at"]))
    |> assign(:start_date, format_date(subscription["start_date"]))
    |> assign(:current_period_end, format_date(subscription["current_period_end"]))
  end

  defp subscription_plan(nil), do: "Trial"

  defp subscription_plan(subscription) do
    subscription
    |> get_in(["items", "data"])
    |> Enum.any?(&(&1["plan"]["id"] == stripe_starter_price_id()))
    |> then(fn starter? -> if(starter?, do: "Starter", else: "Trial") end)
  end

  defp subscription_status(nil), do: nil
  defp subscription_status(subscription), do: subscription["status"]

  defp subscription_cancel_at_period_end(nil), do: nil
  defp subscription_cancel_at_period_end(subscription), do: subscription["cancel_at_period_end"]

  defp format_date(nil), do: "none"

  defp format_date(timestamp) do
    DateTime.from_unix!(timestamp) |> Calendar.strftime("%B %d, %Y")
  end

  defp stripe_starter_price_id() do
    Application.get_env(:canary, :stripe) |> Keyword.fetch!(:starter_price_id)
  end
end

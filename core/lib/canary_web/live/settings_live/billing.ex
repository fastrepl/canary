defmodule CanaryWeb.SettingsLive.Billing do
  use CanaryWeb, :live_view

  alias PrimerLive.Component, as: Primer
  alias Canary.Accounts.Billing

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>Billing</Primer.subhead>
      <p>
        For information about pricing, refer to our <a
          href="https://getcanary.dev/docs/cloud/platform/pricing"
          target="_blank"
        >docs</a>.
      </p>

      <div class="flex flex-col gap-1 text-lg">
        <div>
          You are on <span class="font-semibold text-xl"><%= @subscription_current %></span> plan.
        </div>
        <div>
          <%= @subscription_next %>
        </div>
        <div>
          <%= @subscription_trial %>
        </div>
      </div>

      <div class="flex flex-row gap-2 mt-4 justify-end">
        <%= render_action_button(assigns) %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    stripe_customer_portal_url =
      Application.get_env(:canary, :stripe) |> Keyword.fetch!(:customer_portal_url)

    stripe_starter_price_id =
      Application.get_env(:canary, :stripe) |> Keyword.fetch!(:starter_price_id)

    account = socket.assigns.current_account |> Ash.load!([:billing])
    subscription = account.billing.stripe_subscription

    socket =
      socket
      |> assign(:current_account, account)
      |> assign(:stripe_customer_portal_url, stripe_customer_portal_url)
      |> assign(:stripe_starter_price_id, stripe_starter_price_id)
      |> assign(:subscription_current, subscription_current(subscription))
      |> assign(:subscription_next, subscription_next(subscription))
      |> assign(:subscription_trial, subscription_trial(subscription))

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
        {:error, error} -> {:noreply, socket |> put_flash(:error, error)}
      end
    else
      {:noreply, socket |> redirect(to: ~p"/checkout")}
    end
  end

  defp render_action_button(
         %{
           current_account: %{billing: %{stripe_subscription: %{"status" => status}}}
         } = assigns
       )
       when status in [
              "incomplete",
              "incomplete_expired",
              "trialing",
              "active",
              "past_due",
              "canceled",
              "unpaid",
              "paused"
            ] do
    ~H"""
    <Primer.button href={@stripe_customer_portal_url}>
      Manage
    </Primer.button>
    """
  end

  defp render_action_button(assigns) do
    ~H"""
    <Primer.button type="button" phx-click="checkout" is_primary>
      Upgrade
    </Primer.button>
    """
  end

  defp subscription_current(nil) do
    "Free"
  end

  defp subscription_current(%{"items" => %{"data" => data}, "trial_end" => trial_end}) do
    plan =
      data
      |> Enum.any?(&(&1["plan"]["id"] == stripe_starter_price_id()))
      |> then(fn starter? -> if(starter?, do: "Starter", else: "Free") end)

    if is_nil(trial_end), do: plan, else: "#{plan}(trial)"
  end

  defp subscription_next(nil), do: nil

  defp subscription_next(%{
         "cancel_at_period_end" => true,
         "current_period_end" => current_period_end
       }) do
    "Subscription cancelled, will remain active until #{format_date(current_period_end)}."
  end

  defp subscription_next(%{
         "cancel_at_period_end" => false,
         "current_period_end" => current_period_end
       }) do
    "Subscription will be renewed on #{format_date(current_period_end)}."
  end

  defp subscription_trial(%{
         "trial_end" => trial_end,
         "trial_settings" => %{"end_behavior" => %{"missing_payment_method" => _create_invoice}}
       }) do
    "Trial ends on #{format_date(trial_end)}."
  end

  defp subscription_trial(_), do: nil

  defp format_date(nil), do: "none"
  defp format_date(t), do: DateTime.from_unix!(t) |> Calendar.strftime("%B %d, %Y")

  defp stripe_starter_price_id() do
    Application.get_env(:canary, :stripe) |> Keyword.fetch!(:starter_price_id)
  end
end

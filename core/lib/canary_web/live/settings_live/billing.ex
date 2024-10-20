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

      <div class="my-2">
        <pre>Last 30 days:</pre>
        <pre>Search usage: <%= @search_usage %></pre>
        <pre>Ask usage: <%= @ask_usage %></pre>
      </div>

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
    account = socket.assigns.current_account |> Ash.load!(billing: [:membership])
    membership = account.billing.membership

    {:ok, usage} = Canary.Analytics.query(:last_month_usage, %{account_id: account.id})

    search_usage =
      usage |> Enum.find(%{"type" => "search", "sum" => 0}, &(&1["type"] == "search"))

    ask_usage = usage |> Enum.find(%{"type" => "ask", "sum" => 0}, &(&1["type"] == "ask"))

    socket =
      socket
      |> assign(:current_account, account)
      |> assign(
        :stripe_customer_portal_url,
        Application.fetch_env!(:canary, :stripe_customer_portal_url)
      )
      |> assign(
        :stripe_starter_price_id,
        Application.fetch_env!(:canary, :stripe_starter_price_id)
      )
      |> assign(:subscription_current, compute_subscription_current(membership))
      |> assign(:subscription_next, compute_subscription_next(membership))
      |> assign(:subscription_trial, compute_subscription_trial(membership))
      |> assign(:search_usage, search_usage["sum"])
      |> assign(:ask_usage, ask_usage["sum"])

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
           current_account: %{billing: %{membership: %{status: status}}}
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

  defp compute_subscription_current(membership) do
    plan =
      case membership.tier do
        :admin -> "Admin"
        :starter -> "Starter"
        :free -> "Free"
      end

    if membership.trial do
      "#{plan}(trial)"
    else
      plan
    end
  end

  defp compute_subscription_next(membership) do
    if membership.current_period_end do
      if membership.will_renew do
        "Subscription will be renewed on #{format_date(membership.current_period_end)}."
      else
        "Subscription cancelled, will remain active until #{format_date(membership.current_period_end)}."
      end
    else
      nil
    end
  end

  defp compute_subscription_trial(membership) do
    if membership.trial_end do
      "Trial ends on #{format_date(membership.trial_end)}."
    else
      nil
    end
  end

  defp format_date(nil), do: "none"
  defp format_date(t), do: Calendar.strftime(t, "%B %d, %Y")
end

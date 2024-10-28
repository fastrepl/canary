defmodule CanaryWeb.BillingLive.Plans do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-2">
        For more information, please refer to our <a href="https://getcanary.dev/docs/cloud/platform/pricing">pricing page</a>.
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full bg-white border border-gray-300">
          <thead>
            <tr class="bg-gray-100">
              <th
                :for={
                  value <- [
                    "Name",
                    "Price",
                    "Projects",
                    "Users",
                    "Sources",
                    "Reindex",
                    "Search",
                    "Ask AI",
                    "Analytics",
                    "Action"
                  ]
                }
                class="py-2 px-4 border-b text-left"
              >
                <%= value %>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td
                :for={
                  value <- [
                    "Free",
                    "$0 / mo",
                    "<= #{Canary.Membership.max_projects(:free)}",
                    "<= #{Canary.Membership.max_members(:free)}",
                    "<= #{Canary.Membership.max_sources(:free)}",
                    "Every #{Canary.Membership.refetch_interval_hours(:free)} hours",
                    Canary.Membership.max_searches(:free)
                    |> Number.Delimit.number_to_delimited(precision: 0),
                    Canary.Membership.max_asks(:free)
                    |> Number.Delimit.number_to_delimited(precision: 0),
                    "X",
                    nil
                  ]
                }
                class="py-2 px-4 border-b"
              >
                <%= if value == :action do %>
                  <%= render_action_button(Map.merge(assigns, %{plan: :free})) %>
                <% else %>
                  <%= value %>
                <% end %>
              </td>
            </tr>
            <tr>
              <td
                :for={
                  value <- [
                    "Starter",
                    "$79 / mo",
                    "<= #{Canary.Membership.max_projects(:starter)}",
                    "<= #{Canary.Membership.max_members(:starter)}",
                    "<= #{Canary.Membership.max_sources(:starter)}",
                    "Every #{Canary.Membership.refetch_interval_hours(:starter)} hours",
                    Canary.Membership.max_searches(:starter)
                    |> Number.Delimit.number_to_delimited(precision: 0),
                    Canary.Membership.max_asks(:starter)
                    |> Number.Delimit.number_to_delimited(precision: 0),
                    "O",
                    :action
                  ]
                }
                class="py-2 px-4 border-b"
              >
                <%= if value == :action do %>
                  <%= render_action_button(Map.merge(assigns, %{plan: :starter})) %>
                <% else %>
                  <%= value %>
                <% end %>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    membership = assigns.current_account.billing.membership

    socket =
      socket
      |> assign(assigns)
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

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "checkout",
        _,
        %{assigns: %{current_account: %{billing: billing, id: account_id}}} = socket
      ) do
    if billing.stripe_customer == nil do
      params = %{metadata: %{"account_id" => account_id}}

      with {:ok, customer} <- Stripe.Customer.create(params),
           {:ok, _} <- Canary.Accounts.Billing.update_stripe_customer(billing, customer) do
        {:noreply, socket |> redirect(to: ~p"/checkout")}
      else
        {:error, error} ->
          socket =
            socket
            |> put_flash(:error, error)
            |> push_navigate(to: "/billing")

          {:noreply, socket}
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
    <.button phx-click={JS.navigate(@stripe_customer_portal_url)}>
      Manage
    </.button>
    """
  end

  defp render_action_button(assigns) do
    ~H"""
    <.button type="button" phx-target={@myself} phx-click="checkout" is_primary>
      Upgrade
    </.button>
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

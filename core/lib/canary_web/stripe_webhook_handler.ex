# https://docs.stripe.com/billing/subscriptions/webhooks#events
defmodule CanaryWeb.StripeWebhookHandler do
  @behaviour Stripe.WebhookHandler
  require Logger

  @impl true
  def handle_event(%Stripe.Event{type: type, data: data})
      when type in ["customer.created", "customer.updated"] do
    %{object: %Stripe.Customer{} = customer} = data

    case Ash.get(Canary.Accounts.Account, customer.metadata["account_id"]) do
      {:ok, account} ->
        biling = account |> Ash.load!(:billing) |> Map.get(:billing)
        Canary.Accounts.Billing.update_stripe_customer(biling, customer)

      {:error, error} ->
        Logger.error(error)
        :error
    end

    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: type, data: data})
      when type in [
             "customer.subscription.created",
             "customer.subscription.updated",
             "customer.subscription.deleted"
           ] do
    %{object: %Stripe.Subscription{customer: id} = subscription} = data

    with {:ok, %Stripe.Customer{} = customer} <- Stripe.Customer.retrieve(id),
         {:ok, account} <- Ash.get(Canary.Accounts.Account, customer.metadata["account_id"]) do
      biling = account |> Ash.load!(:billing) |> Map.get(:billing)
      Canary.Accounts.Billing.update_stripe_subscription(biling, subscription)
    else
      {:error, error} ->
        Logger.error(error)
        :error
    end
  end

  @impl true
  def handle_event(_event), do: :ok
end

# https://docs.stripe.com/billing/subscriptions/webhooks#events
defmodule CanaryWeb.StripeWebhookHandler do
  @behaviour Stripe.WebhookHandler

  @impl true
  def handle_event(%Stripe.Event{type: type, data: data})
      when type in ["customer.created", "customer.updated"] do
    %{object: %Stripe.Customer{} = customer} = data
    IO.inspect(customer.metadata)
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: type, data: data})
      when type in ["customer.subscription.created", "customer.subscription.updated"] do
    %{object: %Stripe.Subscription{customer: id}} = data

    case Stripe.Customer.retrieve(id) do
      {:ok, %Stripe.Customer{} = customer} -> IO.inspect(customer.metadata)
      error -> error
    end
  end

  @impl true
  def handle_event(_event), do: :ok
end

defmodule CanaryWeb.CheckoutController do
  use CanaryWeb, :controller
  require Logger

  @trial_period_days 7

  def session(%{assigns: %{current_account: current_account}} = conn, _params) do
    url = CanaryWeb.Endpoint.url()
    price = Application.get_env(:canary, :stripe) |> Keyword.fetch!(:starter_price_id)

    base_params = %{
      ui_mode: :hosted,
      mode: :subscription,
      line_items: [%{price: price, quantity: 1}],
      success_url: url <> "/settings",
      cancel_url: url <> "/settings",
      metadata: %{"account_id" => current_account.id},
      subscription_data: %{
        trial_period_days: @trial_period_days
      }
    }

    params =
      case Ash.load!(current_account, :billing).billing.stripe_customer do
        nil -> base_params
        customer -> base_params |> Map.put(:customer, customer["id"])
      end

    case Stripe.Checkout.Session.create(params) do
      {:ok, %Stripe.Checkout.Session{} = session} ->
        conn
        |> put_status(303)
        |> redirect(external: session.url)

      {:error, error} ->
        Logger.error(error)
        conn |> redirect(to: "/")
    end
  end
end

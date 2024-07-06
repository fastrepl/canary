defmodule CanaryWeb.CheckoutController do
  use CanaryWeb, :controller
  require Logger

  def seat(conn, _params) do
    url = CanaryWeb.Endpoint.url()
    price = Application.get_env(:canary, :stripe) |> Keyword.fetch!(:seat_price_id)

    params = %{
      ui_mode: :hosted,
      mode: :subscription,
      line_items: [%{price: price, quantity: 1}],
      success_url: url <> "/settings",
      cancel_url: url <> "/settings",
      automatic_tax: %{enabled: true},
      metadata: %{"account_id" => "TODO"}
    }

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

  def chat(conn, _params) do
    url = CanaryWeb.Endpoint.url()
    price = Application.get_env(:canary, :stripe) |> Keyword.fetch!(:chat_price_id)

    params = %{
      ui_mode: :hosted,
      mode: :subscription,
      line_items: [%{price: price}],
      success_url: url <> "/settings",
      cancel_url: url <> "/settings",
      automatic_tax: %{enabled: true},
      metadata: %{"account_id" => "TODO"}
    }

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

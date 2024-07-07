defmodule Canary.Payment do
  @callback sync_seats(account :: map()) :: {:ok, map()} | {:error, any()}

  def sync_seats(account), do: impl().sync_seats(account)

  defp impl(), do: Application.get_env(:canary, :payment, Canary.Payment.Stripe)
end

defmodule Canary.Payment.Stripe do
  @behaviour Canary.Payment
  @dialyzer {:nowarn_function, sync_seats: 1}

  @free_seats 1

  def sync_seats(%Canary.Accounts.Account{} = account) do
    account = account |> Ash.load!([:users, :billing])

    billable_seats = Enum.count(account.users) - @free_seats
    subscription = account.billing.stripe_subscription

    item =
      subscription["items"]["data"]
      |> Enum.find(fn item -> item["price"]["id"] == seat_price_id() end)

    case item do
      nil ->
        :error

      item ->
        subscription["id"]
        |> Stripe.Subscription.update(%{
          items: [%{id: item["id"], price: seat_price_id(), quantity: billable_seats}]
        })
    end

    {:ok, %{quantity: billable_seats}}
  end

  defp seat_price_id, do: Application.get_env(:canary, :stripe) |> Keyword.fetch!(:seat_price_id)
end

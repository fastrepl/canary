defmodule Canary.Payment do
  @callback sync_seats(account :: map()) :: {:ok, map()} | {:error, any()}
  @callback sync_chats(account :: map()) :: {:ok, map()} | {:error, any()}

  def sync_seats(account), do: impl().sync_seats(account)
  def sync_chats(account), do: impl().sync_chats(account)

  defp impl(), do: Application.get_env(:canary, :payment, Canary.Payment.Stripe)
end

defmodule Canary.Payment.Stripe do
  @behaviour Canary.Payment
  @dialyzer {:nowarn_function, sync_seats: 1}

  def sync_seats(%Canary.Accounts.Account{} = account) do
    account = account |> Ash.load!([:users, :billing])
    subscription = account.billing.stripe_subscription

    case find_item(subscription, seat_price_id()) do
      nil ->
        :error

      item ->
        subscription["id"]
        |> Stripe.Subscription.update(%{
          items: [%{id: item["id"], price: seat_price_id(), quantity: Enum.count(account.users)}]
        })
    end
  end

  def sync_chats(%Canary.Accounts.Account{} = account) do
    account = account |> Ash.load!([:billing, :chat_usage_last_hour])
    subscription = account.billing.stripe_subscription

    case find_item(subscription, chat_price_id()) do
      nil ->
        :error

      item ->
        item["id"]
        |> Stripe.UsageRecord.create(%{
          action: :set,
          quantity: account.chat_usage_last_hour,
          timestamp: DateTime.utc_now() |> DateTime.to_unix()
        })
    end
  end

  defp find_item(subscription, price_id) do
    subscription["items"]["data"]
    |> Enum.find(fn item -> item["price"]["id"] == price_id end)
  end

  defp seat_price_id, do: Application.get_env(:canary, :stripe) |> Keyword.fetch!(:seat_price_id)
  defp chat_price_id, do: Application.get_env(:canary, :stripe) |> Keyword.fetch!(:chat_price_id)
end

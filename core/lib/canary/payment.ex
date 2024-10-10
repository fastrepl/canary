defmodule Canary.Payment do
  @callback sync_ask(account :: map()) :: {:ok, map()} | {:error, any()}
  @callback sync_search(account :: map()) :: {:ok, map()} | {:error, any()}

  def sync_ask(account), do: impl().sync_chats(account)
  def sync_search(account), do: impl().sync_search(account)

  defp impl(), do: Application.get_env(:canary, :payment, Canary.Payment.Stripe)
end

defmodule Canary.Payment.Stripe do
  @behaviour Canary.Payment

  def sync_ask(%Canary.Accounts.Account{} = account) do
    account = account |> Ash.load!([:billing])
    subscription = account.billing.stripe_subscription

    case find_item(subscription, ask_price_id()) do
      nil ->
        :error

      item ->
        item["id"]
        |> Stripe.UsageRecord.create(%{
          action: :set,
          quantity: account.billing.count_ask,
          timestamp: DateTime.utc_now() |> DateTime.to_unix()
        })
    end
  end

  def sync_search(%Canary.Accounts.Account{} = account) do
    account = account |> Ash.load!([:billing])
    subscription = account.billing.stripe_subscription

    case find_item(subscription, search_price_id()) do
      nil ->
        :error

      item ->
        item["id"]
        |> Stripe.UsageRecord.create(%{
          action: :set,
          quantity: account.billing.count_search,
          timestamp: DateTime.utc_now() |> DateTime.to_unix()
        })
    end
  end

  defp find_item(subscription, price_id) do
    subscription["items"]["data"]
    |> Enum.find(fn item -> item["price"]["id"] == price_id end)
  end

  defp stripe_config(), do: Application.get_env(:canary, :stripe)

  defp ask_price_id, do: stripe_config() |> Keyword.fetch!(:ask_price_id)
  defp search_price_id, do: stripe_config() |> Keyword.fetch!(:search_price_id)
end

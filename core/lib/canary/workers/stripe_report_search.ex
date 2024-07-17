defmodule Canary.Workers.StripeReportSearch do
  use Oban.Worker, queue: :stripe, max_attempts: 1

  @impl true
  def perform(%Oban.Job{args: %{"account_id" => account_id}}) do
    with {:ok, account} <- Ash.get(Canary.Accounts.Account, account_id, load: [:billing]),
         {:ok, _} <- Canary.Payment.sync_search(account),
         {:ok, _} <- Canary.Accounts.Billing.reset_search(account.billing) do
      :ok
    else
      error -> error
    end
  end
end

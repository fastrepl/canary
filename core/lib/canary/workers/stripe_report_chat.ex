defmodule Canary.Workers.StripeReportChat do
  use Oban.Worker, queue: :stripe, max_attempts: 3

  @impl true
  def perform(%Oban.Job{args: %{"account_id" => account_id}}) do
    with {:ok, account} <- Ash.get(Canary.Accounts.Account, account_id),
         {:ok, _} <- Canary.Payment.sync_chats(account) do
      :ok
    else
      error -> error
    end
  end
end

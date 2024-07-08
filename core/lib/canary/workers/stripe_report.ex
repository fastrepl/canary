defmodule Canary.Workers.StripeReport do
  use Oban.Worker, queue: :stripe, max_attempts: 2
  require Ash.Query

  @impl true
  def perform(%Oban.Job{}) do
    accounts =
      Canary.Accounts.Account
      |> Ash.Query.filter(not is_nil(billing.stripe_subscription))
      |> Ash.read!()

    accounts
    |> Enum.map(&%{account_id: &1.id})
    |> Enum.map(&Canary.Workers.StripeReportChat.new/1)
    |> Oban.insert_all()

    :ok
  end
end

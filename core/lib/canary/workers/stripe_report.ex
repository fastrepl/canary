defmodule Canary.Workers.StripeReport do
  use Oban.Worker, queue: :stripe, max_attempts: 1
  require Ash.Query

  @impl true
  def perform(%Oban.Job{}) do
    accounts =
      Canary.Accounts.Account
      |> Ash.Query.filter(not is_nil(billing.stripe_subscription))
      |> Ash.read!()

    accounts
    |> Enum.map(&%{account_id: &1.id})
    |> Enum.flat_map(fn account ->
      [
        Canary.Workers.StripeReportAsk.new(%{account_id: account.id}),
        Canary.Workers.StripeReportSearch.new(%{account_id: account.id})
      ]
    end)
    |> Oban.insert_all()

    :ok
  end
end

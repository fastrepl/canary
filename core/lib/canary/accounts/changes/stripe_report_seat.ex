defmodule Canary.Accounts.Changes.StripeReportSeat do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.after_transaction(fn _changeset, result ->
      case result do
        {:ok, account} ->
          Canary.Payment.sync_seats(account)
          {:ok, account}

        error ->
          error
      end
    end)
  end
end

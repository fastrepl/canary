defmodule Canary.Accounts.Changes.InitUsage do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.after_action(fn _, account ->
      case Canary.Accounts.Usage
           |> Ash.Changeset.for_create(:create, %{account: account})
           |> Ash.create() do
        {:ok, _} -> {:ok, account}
        error -> error
      end
    end)
  end
end

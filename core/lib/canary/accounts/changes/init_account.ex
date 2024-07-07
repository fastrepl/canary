defmodule Canary.Accounts.Changes.InitAccount do
  use Ash.Resource.Change

  @default_account_name "Default"

  @impl true
  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.after_action(fn _, user ->
      case Canary.Accounts.Account
           |> Ash.Changeset.for_create(:create, %{user: user, name: @default_account_name})
           |> Ash.create() do
        {:ok, _} -> {:ok, user}
        error -> error
      end
    end)
  end
end

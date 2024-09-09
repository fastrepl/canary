defmodule Canary.Accounts.Changes.InitKey do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, account ->
      case Canary.Accounts.Key
           |> Ash.Changeset.for_create(:create, %{
             account_id: account.id,
             config: %Ash.Union{type: :public, value: %Canary.Accounts.PublicKeyConfig{}}
           })
           |> Ash.create() do
        {:ok, _} -> {:ok, account}
        error -> error
      end
    end)
  end
end

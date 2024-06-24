defmodule Canary.AccountsFixtures do
  def account_fixture() do
    Canary.Accounts.Account
    |> Ash.Changeset.for_create(:create, %{name: "TEST", user_id: Ash.UUID.generate()})
    |> Ash.create!()
  end
end

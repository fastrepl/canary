defmodule Canary.AccountsFixtures do
  def account_fixture() do
    user =
      Canary.Accounts.User
      |> Ash.Changeset.for_create(:mock, %{email: "test@example.com", hashed_password: "TEST"})
      |> Ash.create!()

    Canary.Accounts.Account
    |> Ash.Changeset.for_create(:create, %{name: "TEST", user: user})
    |> Ash.create!()
  end
end

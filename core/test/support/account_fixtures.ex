defmodule Canary.AccountsFixtures do
  def account_fixture() do
    email = "#{random_string()}@example.com"
    password = random_string(12)
    account_name = random_string(8)

    user =
      Canary.Accounts.User
      |> Ash.Changeset.for_create(:mock, %{email: email, hashed_password: password})
      |> Ash.create!()

    Canary.Accounts.Account
    |> Ash.Changeset.for_create(:create, %{name: account_name, user: user})
    |> Ash.create!()
  end

  defp random_string(length \\ 10) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end

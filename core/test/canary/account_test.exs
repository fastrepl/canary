defmodule Canary.Test.Account do
  use Canary.DataCase
  import Canary.AccountsFixtures
  import Canary.UsersFixtures

  alias Canary.Accounts.Account

  test "add and remove member" do
    account = account_fixture()
    user = user_fixture()

    assert account.users |> length() == 1
    {:ok, account} = Account.add_member(account, user.id)
    assert account.users |> length() == 1 + 1
    {:ok, account} = Account.remove_member(account, user.id)
    assert account.users |> length() == 1 + 1 - 1
  end
end

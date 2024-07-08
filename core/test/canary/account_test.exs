defmodule Canary.Test.Account do
  use Canary.DataCase
  import Canary.AccountsFixtures
  import Canary.UsersFixtures

  import Mox
  setup :verify_on_exit!

  alias Canary.Accounts.Account
  alias Canary.Interactions.{Session, Message}

  test "add and remove member" do
    Canary.Payment.Mock
    |> expect(:sync_seats, 2, fn _ -> {:ok, %{}} end)

    account = account_fixture()
    user = user_fixture()

    assert account.users |> length() == 1
    {:ok, account} = Account.add_member(account, user)
    assert account.users |> length() == 1 + 1
    {:ok, account} = Account.remove_member(account, user)
    assert account.users |> length() == 1 + 1 - 1
  end

  test "chat usage" do
    account = account_fixture() |> Ash.load!(:chat_usage_last_hour)
    assert account.chat_usage_last_hour == 0

    session = Session.create_with_discord!(account, 1)
    Message.add_user!(session, "hi")
    Message.add_assistant!(session, "hi")

    account = account |> Ash.load!(:chat_usage_last_hour)
    assert account.chat_usage_last_hour == 0 + 1
  end
end

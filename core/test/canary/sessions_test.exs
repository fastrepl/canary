defmodule Canary.Test.Session do
  use Canary.DataCase
  import Canary.AccountsFixtures
  require Ash.Query

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "resource" do
    test "it can be created" do
      account = account_fixture()

      session_1 = Canary.Sessions.Session.create_with_discord!(account, 1)
      session_2 = Canary.Sessions.Session.create_with_web!(account, "123")

      assert session_1.id != session_2.id
      assert session_1.account_id == session_2.account_id
    end

    test "it can be found" do
      account = account_fixture()
      session_1 = Canary.Sessions.Session.create_with_discord!(account, 1)
      session_2 = Canary.Sessions.Session.create_with_web!(account, "123")

      {:ok, session_3} = Canary.Sessions.Session.find_with_discord(account.id, 1)
      {:ok, session_4} = Canary.Sessions.Session.find_with_web(account.id, "123")
      {:error, _} = Canary.Sessions.Session.find_with_discord(account.id, 2)

      assert session_1.id == session_3.id
      assert session_2.id == session_4.id
    end

    test "it can have messages" do
      session = Canary.Sessions.Session.create_with_discord!(account_fixture(), 1)
      msg_1 = Canary.Sessions.Message.add_user!(session, "Hello!")
      msg_2 = Canary.Sessions.Message.add_assistant!(session, "Hi!")

      session = session |> Ash.load!([:messages, :started_at, :ended_at])

      assert length(session.messages) == 2
      assert session.messages |> get_in([Access.at(0), Access.key(:role)]) == :user
      assert session.messages |> get_in([Access.at(1), Access.key(:role)]) == :assistant
      assert session.started_at == msg_1.created_at
      assert session.ended_at == msg_2.created_at
    end
  end
end

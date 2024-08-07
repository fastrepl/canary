defmodule Canary.Test.Session do
  use Canary.DataCase
  import Canary.AccountsFixtures

  test "find_or_create_session" do
    account = account_fixture()
    {:ok, session_1} = Canary.Interactions.find_or_create_session(account, {:web, 1})
    {:ok, session_2} = Canary.Interactions.find_or_create_session(account, {:web, 2})
    {:ok, session_3} = Canary.Interactions.find_or_create_session(account, {:web, 1})

    assert session_1.id != session_2.id
    assert session_1.id == session_3.id
  end

  test "create message" do
    account = account_fixture()
    {:ok, session} = Canary.Interactions.find_or_create_session(account, {:web, 1})

    Canary.Interactions.Message.add_user!(session, "hi")
    Canary.Interactions.Message.add_assistant!(session, "hello")

    session = session |> Ash.load!(:messages)
    assert session.messages |> length() == 2
  end
end

defmodule Canary.Test.Interactions do
  use Canary.DataCase
  import Canary.AccountsFixtures

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  alias Canary.Sources.Source
  alias Canary.Interactions.Session
  alias Canary.Interactions.Client

  describe "session" do
    test "create / find" do
      account = account_fixture()

      session_1 = Session.create_with_discord!(account, 1)
      session_2 = Session.create_with_web!(account, 2)

      assert session_1.id != session_2.id
      assert session_1.account_id == session_2.account_id

      {:ok, session_3} = Session.find_with_discord(account.id, 1)
      assert session_3.id == session_1.id

      {:error, _} = Session.find_with_discord(account.id, 2)
    end
  end

  describe "client" do
    test "create / find" do
      account = account_fixture()
      source = Source.create!(account, :docusaurus, "https://example.com", "/docs")

      client_1 = Client.create_discord!(source, "discord/1", 1, 2)
      client_2 = Client.create_discord!(source, "discord/2", 3, 4)
      assert client_1.id != client_2.id

      {:ok, client_3} = Client.find_discord(1, 2)
      assert client_3.id == client_1.id
      assert client_3.source_id == source.id

      {:error, _} = Client.find_discord(3, 3)
    end
  end
end

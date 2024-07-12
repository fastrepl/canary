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
    test "create and find" do
      account = account_fixture()

      client_1 = Client.create_web!(account, "https://example.com")
      client_2 = Client.create_web!(account, "https://getcanary.dev")
      client_3 = Client.create_discord!(account, 1, 2)

      assert client_1.web_public_key != client_2.web_public_key
      assert client_3.web_public_key == nil

      client = Client.find_web!(client_1.web_public_key)
      assert client.id == client_1.id
      assert client.web_host_url == "example.com"
    end

    test "modify sources" do
      account = account_fixture()
      source = Source.create_web!(account, "https://example.com")

      client = Client.create_web!(account, "https://example.com") |> Ash.load!(:sources)
      client = client |> Ash.load!(:sources)
      assert client.sources |> length() == 0

      client = Client.add_sources!(client, [source]) |> Ash.load!(:sources)
      assert client.sources |> length() == 1
    end
  end
end

defmodule Canary.ClientsTest do
  use Canary.DataCase
  import Canary.AccountsFixtures
  require Ash.Query

  test "many_to_many with sources" do
    account = account_fixture()

    client =
      Canary.Clients.Client
      |> Ash.Changeset.for_create(:create_discord, %{
        account_id: account.id,
        discord_server_id: 1,
        discord_channel_id: 2
      })
      |> Ash.create!()

    source_1 =
      Canary.Sources.Source
      |> Ash.Changeset.for_create(:create_web, %{
        account_id: account.id,
        web_base_url: "https://example.com"
      })
      |> Ash.create!()

    source_2 =
      Canary.Sources.Source
      |> Ash.Changeset.for_create(:create_web, %{
        account_id: account.id,
        web_base_url: "https://example2.com"
      })
      |> Ash.create!()

    client
    |> Ash.Changeset.for_update(:add_sources, %{sources: [%{id: source_1.id}, %{id: source_2.id}]})
    |> Ash.update!()

    found =
      Canary.Clients.Client
      |> Ash.Query.for_read(:find_discord, %{discord_server_id: 1, discord_channel_id: 2})
      |> Ash.read_one!()

    assert found.id == client.id
    assert length(found.sources) == 2

    client = client |> Ash.load!(:sources)
    assert length(client.sources) == 2

    client
    |> Ash.Changeset.for_update(:remove_sources, %{sources: [%{id: source_1.id}]})
    |> Ash.update!()

    client = client |> Ash.load!(:sources)
    assert length(client.sources) == 1
  end
end

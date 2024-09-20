defmodule Canary.Test.Source do
  use Canary.DataCase
  import Canary.AccountsFixtures

  test "create" do
    account = account_fixture()
    config = %Ash.Union{type: :webpage, value: %Canary.Sources.Webpage.Config{}}

    source =
      Canary.Sources.Source
      |> Ash.Changeset.new()
      |> Ash.Changeset.for_create(:create, %{
        account_id: account.id,
        name: "Docs",
        config: config
      })
      |> Ash.create!()

    assert source.account.id == account.id
    assert source.config.type == :webpage
  end

  test "destroy" do
    account = account_fixture()
    config = %Ash.Union{type: :webpage, value: %Canary.Sources.Webpage.Config{}}

    source =
      Canary.Sources.Source
      |> Ash.Changeset.new()
      |> Ash.Changeset.for_create(:create, %{
        account_id: account.id,
        name: "Docs",
        config: config
      })
      |> Ash.create!()

    assert source.name == "Docs"

    source
    |> Ash.Changeset.for_action(:destroy)
    |> Ash.destroy()
  end
end

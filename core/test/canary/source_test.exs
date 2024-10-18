defmodule Canary.Test.Source do
  use Canary.DataCase
  import Canary.AccountsFixtures

  test "create" do
    account = account_fixture()
    project = Canary.Accounts.Project.create!(account.id, "project")
    config = %Ash.Union{type: :webpage, value: %Canary.Sources.Webpage.Config{}}

    source =
      Canary.Sources.Source
      |> Ash.Changeset.new()
      |> Ash.Changeset.for_create(
        :create,
        %{
          project_id: project.id,
          name: "Docs",
          config: config
        },
        authorize?: false
      )
      |> Ash.create!()

    assert source.project.id == project.id
    assert source.config.type == :webpage
  end

  test "destroy" do
    account = account_fixture()
    project = Canary.Accounts.Project.create!(account.id, "project")
    config = %Ash.Union{type: :webpage, value: %Canary.Sources.Webpage.Config{}}

    source =
      Canary.Sources.Source
      |> Ash.Changeset.new()
      |> Ash.Changeset.for_create(
        :create,
        %{
          project_id: project.id,
          name: "Docs",
          config: config
        },
        authorize?: false
      )
      |> Ash.create!()

    assert source.name == "Docs"

    source
    |> Ash.Changeset.for_action(:destroy)
    |> Ash.destroy()
  end
end

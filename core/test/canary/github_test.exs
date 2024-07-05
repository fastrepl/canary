defmodule Canary.Test.Github do
  use Canary.DataCase
  import Canary.AccountsFixtures
  require Ash.Query

  alias Canary.Github

  test "create app and repo" do
    account = account_fixture()
    app = Github.App.create!(1, [], account)

    repo = Github.Repo.create!(app, "a/b")
    assert repo.full_name == "a/b"
  end

  test "create app with repos" do
    account = account_fixture()
    app = Github.App.create!(1, ["a/b", "c/d"], account)
    app = app |> Ash.load!(:repos)
    assert app.repos |> length() == 0 + 2
  end

  test "link account" do
    account = account_fixture()
    app = Github.App.create!(1) |> Github.App.link_account!(account)
    assert app.account.id == account.id
  end

  test "find app" do
    account = account_fixture()
    app = Github.App.create!(1, [], account)

    assert Github.App.find!(1).id == app.id
    {:error, _} = Github.App.find(2)
  end

  test "create multiple repos" do
    account = account_fixture()
    app = Github.App.create!(1, [], account)

    assert Github.Repo |> Ash.read!() |> length() == 0

    ["a/b", "c/d"]
    |> Enum.map(&%{app: app, full_name: &1})
    |> Ash.bulk_create(Github.Repo, :create)

    assert Github.Repo |> Ash.read!() |> length() == 0 + 2

    ["a/b", "e/f"]
    |> Enum.map(&%{app: app, full_name: &1})
    |> Ash.bulk_create(Github.Repo, :create)

    assert Github.Repo |> Ash.read!() |> length() == 0 + 2 + (2 - 1)
  end

  test "remove app" do
    account = account_fixture()
    app = Github.App.create!(1, [], account)

    ["a/b", "c/d", "e/f"]
    |> Enum.map(&%{app: app, full_name: &1})
    |> Ash.bulk_create(Github.Repo, :create)

    assert Github.App |> Ash.read!() |> length() == 0 + 1
    assert Github.Repo |> Ash.read!() |> length() == 0 + 3

    Github.App.delete!(app.installation_id)

    assert Github.App |> Ash.read!() |> length() == 0 + 1 - 1
    assert Github.Repo |> Ash.read!() |> length() == 0 + 3 - 3
  end

  test "remove multiple repos" do
    account = account_fixture()
    app = Github.App.create!(1, [], account)

    ["a/b", "c/d", "e/f"]
    |> Enum.map(&%{app: app, full_name: &1})
    |> Ash.bulk_create(Github.Repo, :create)

    assert Github.Repo |> Ash.read!() |> length() == 0 + 3
    Github.Repo.delete!(app, ["a/b", "e/f"])
    assert Github.Repo |> Ash.read!() |> length() == 0 + 3 - 2
  end
end

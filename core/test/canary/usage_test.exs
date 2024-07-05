defmodule Canary.Test.Usage do
  use Canary.DataCase
  import Canary.AccountsFixtures

  test "updating usage" do
    account = account_fixture() |> Ash.load!(:usage)
    assert account.usage.generation == 0

    account.usage
    |> Ash.Changeset.for_update(:increment_generation)
    |> Ash.update!()

    account = account |> Ash.load!(:usage)
    assert account.usage.generation == 0 + 1

    account.usage
    |> Ash.Changeset.for_update(:reset)
    |> Ash.update!()

    account = account |> Ash.load!(:usage)
    assert account.usage.generation == 0
  end
end

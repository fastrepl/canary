defmodule Canary.Test.Project do
  use Canary.DataCase

  import Canary.AccountsFixtures

  test "soft destroy" do
    account = account_fixture()
    project_1 = Canary.Accounts.Project.create!(account.id, "project_1", authorize?: false)
    project_2 = Canary.Accounts.Project.create!(account.id, "project_2", authorize?: false)

    assert Canary.Accounts.Project
           |> Ash.Query.for_read(:read)
           |> Ash.read!()
           |> length() == 2

    assert project_1.id != project_2.id
    Ash.destroy!(project_1)

    assert Canary.Accounts.Project
           |> Ash.Query.for_read(:read)
           |> Ash.read!()
           |> length() == 1

    assert Canary.Accounts.Project
           |> Ash.Query.for_read(:read_all)
           |> Ash.read!()
           |> length() == 2

    assert Ash.reload!(project_1, action: :read_all).archived_at != nil
    assert Ash.reload!(project_2, action: :read_all).archived_at == nil
  end
end

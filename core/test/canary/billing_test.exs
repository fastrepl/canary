defmodule Canary.BillingTest do
  use Canary.DataCase
  import Canary.AccountsFixtures
  require Ash.Query

  alias Canary.Accounts.Billing

  test "account has billing" do
    account = account_fixture()
    account = account |> Ash.load!(:billing)
    assert account.billing != nil
  end

  test "update billing" do
    account = account_fixture()
    account = account |> Ash.load!(:billing)

    assert account.billing.stripe_customer == nil
    assert account.billing.stripe_subscription == nil

    args = %{
      stripe_customer: %{id: "cus_123"},
      stripe_subscription: %{id: "sub_123"}
    }

    updated =
      account.billing
      |> Ash.Changeset.for_update(:update, args)
      |> Ash.update!()

    [found] =
      Billing
      |> Ash.Query.filter(stripe_customer[:id] == ^args.stripe_customer.id)
      |> Ash.Query.limit(1)
      |> Ash.read!()

    assert found.id == updated.id
  end
end

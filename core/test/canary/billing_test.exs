defmodule Canary.Test.Billing do
  use Canary.DataCase
  import Canary.AccountsFixtures
  require Ash.Query

  alias Canary.Accounts.Billing

  test "account has billing" do
    account = account_fixture()
    account = account |> Ash.load!(:billing)
    assert account.billing != nil
  end

  test "update stripe" do
    account = account_fixture()
    account = account |> Ash.load!(:billing)

    assert account.billing.stripe_customer == nil
    assert account.billing.stripe_subscription == nil

    updated = Billing.update_stripe_customer!(account.billing, %{id: "cus_123"})
    updated = Billing.update_stripe_customer!(account.billing, %Stripe.Customer{id: "cus_123"})

    [found] =
      Billing
      |> Ash.Query.filter(stripe_customer[:id] == "cus_123")
      |> Ash.Query.limit(1)
      |> Ash.read!()

    assert found.id == updated.id
  end

  test "update usage" do
    account = account_fixture()
    account = account |> Ash.load!(:billing)

    assert account.billing.count_ask == 0
    assert account.billing.count_search == 0

    updated = Billing.increment_ask!(account.billing)
    assert updated.count_ask == 1
    assert updated.count_search == 0

    updated = Billing.increment_search!(account.billing)
    assert updated.count_ask == 1
    assert updated.count_search == 1

    updated = Billing.reset_ask!(account.billing)
    assert updated.count_ask == 0
    assert updated.count_search == 1
  end
end

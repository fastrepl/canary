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

    updated_1 = Billing.update_stripe_customer!(account.billing, %{id: "cus_123"})
    updated_2 = Billing.update_stripe_customer!(account.billing, %Stripe.Customer{id: "cus_123"})

    found =
      Billing
      |> Ash.Query.filter(stripe_customer[:id] == "cus_123")
      |> Ash.read_one!()

    assert found.id == updated_1.id
    assert found.id == updated_2.id
  end
end

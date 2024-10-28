defmodule Canary.Membership do
  def can_use_insights?(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> false
      :starter -> true
      :admin -> true
      _ -> false
    end
  end

  def can_use_ask?(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> false
      :starter -> true
      :admin -> true
      _ -> false
    end
  end

  def max_sources(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> 1
      :starter -> 3
      :admin -> 9999
      _ -> 0
    end
  end

  def max_projects(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> 1
      :starter -> 3
      :admin -> 9999
      _ -> 0
    end
  end

  def max_members(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> 1
      :starter -> 3
      :admin -> 9999
      _ -> 0
    end
  end

  def max_searches(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> 30 * 1000
      :starter -> 1000 * 1000
      :admin -> 1000 * 1000
      _ -> 0
    end
  end

  def max_asks(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> 100
      :starter -> 1000
      :admin -> 1000 * 1000
      _ -> 0
    end
  end

  def refetch_interval_hours(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> 24 * 3
      :starter -> 24 * 1
      _ -> 24 * 30 * 12 * 10
    end
  end

  defp ensure_membership(account) do
    try do
      account.billing.membership
      account
    rescue
      _ ->
        account |> Ash.load!(billing: [:membership])
    end
  end
end

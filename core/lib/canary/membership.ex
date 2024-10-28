defmodule Canary.Membership do
  def can_use_insights?(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> false
      :starter -> true
      :admin -> true
    end
  end

  def can_use_ask?(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> false
      :starter -> true
      :admin -> true
    end
  end

  def max_projects(:free), do: 1
  def max_projects(:starter), do: 3
  def max_projects(:admin), do: 9999

  def max_projects(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> Canary.Membership.max_projects(:free)
      :starter -> Canary.Membership.max_projects(:starter)
      :admin -> Canary.Membership.max_projects(:admin)
    end
  end

  def max_sources(:free), do: 3
  def max_sources(:starter), do: 9
  def max_sources(:admin), do: 9999

  def max_sources(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> Canary.Membership.max_sources(:free)
      :starter -> Canary.Membership.max_sources(:starter)
      :admin -> Canary.Membership.max_sources(:admin)
    end
  end

  def max_members(:free), do: 1
  def max_members(:starter), do: 3
  def max_members(:admin), do: 9999

  def max_members(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> Canary.Membership.max_members(:free)
      :starter -> Canary.Membership.max_members(:starter)
      :admin -> Canary.Membership.max_members(:admin)
    end
  end

  def max_searches(:free), do: 1000 * 1000
  def max_searches(:starter), do: 10 * 1000 * 1000
  def max_searches(:admin), do: 1000 * 1000 * 1000

  def max_searches(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> Canary.Membership.max_searches(:free)
      :starter -> Canary.Membership.max_searches(:starter)
      :admin -> Canary.Membership.max_searches(:admin)
    end
  end

  def max_asks(:free), do: 0
  def max_asks(:starter), do: 3 * 1000
  def max_asks(:admin), do: 1000 * 1000

  def max_asks(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> Canary.Membership.max_asks(:free)
      :starter -> Canary.Membership.max_asks(:starter)
      :admin -> Canary.Membership.max_asks(:admin)
    end
  end

  def refetch_interval_hours(:free), do: 24 * 4
  def refetch_interval_hours(:starter), do: 24 * 1
  def refetch_interval_hours(:admin), do: 24 * 30 * 12 * 10

  def refetch_interval_hours(%Canary.Accounts.Account{} = account) do
    account = ensure_membership(account)

    case account.billing.membership.tier do
      :free -> Canary.Membership.refetch_interval_hours(:free)
      :starter -> Canary.Membership.refetch_interval_hours(:starter)
      :admin -> Canary.Membership.refetch_interval_hours(:admin)
    end
  end

  defp ensure_membership(account) do
    try do
      account.billing.membership
      account
    rescue
      _ ->
        billing_query =
          Canary.Accounts.Billing
          |> Ash.Query.select([:id])
          |> Ash.Query.load(:membership)

        account |> Ash.load!(billing: billing_query)
    end
  end
end

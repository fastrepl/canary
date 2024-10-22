defmodule Canary.Membership do
  def can_use_insights?(%Canary.Accounts.Account{} = account) do
    account = account |> Ash.load!(billing: [:membership])

    case account.billing.membership.tier do
      :free -> false
      :starter -> true
      :admin -> true
      _ -> false
    end
  end
end

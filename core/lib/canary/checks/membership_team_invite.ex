defmodule Canary.Checks.Membership.TeamInvite do
  use Ash.Policy.SimpleCheck
  require Ash.Query

  def describe(_) do
    "actor has correct membership to invite more members"
  end

  def match?(
        %Canary.Accounts.Account{} = account,
        %Ash.Policy.Authorizer{
          resource: Canary.Accounts.Invite,
          changeset: %Ash.Changeset{relationships: %{account: [{[%{id: account_id}], _}]}}
        },
        _opts
      ) do
    with {:ok, %{num_members: num_members, billing: billing}} <-
           Ash.load(account, [:num_members, billing: [:membership]]),
         {:ok, num_invites} <-
           Canary.Accounts.Invite
           |> Ash.Query.for_read(:not_expired, actor: account)
           |> Ash.count() do
      cond do
        account != account_id ->
          {:ok, false}

        billing.membership.tier == :free ->
          {:ok, false}

        billing.membership.tier == :starter and num_invites + num_members < 4 ->
          {:ok, true}

        true ->
          {:ok, false}
      end
    end

    {:ok, true}
  end

  def match?(_, _, _), do: false
end

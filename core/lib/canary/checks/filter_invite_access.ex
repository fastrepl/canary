defmodule Canary.Checks.Filter.InviteAccess do
  use Ash.Policy.FilterCheck

  @impl true
  def describe(_) do
    "actor has correct access to invite"
  end

  @impl true
  def filter(
        _,
        %Ash.Policy.Authorizer{
          resource: Canary.Accounts.Invite,
          actor: %Canary.Accounts.Account{id: _}
        },
        _opts
      ) do
    expr(account_id == ^actor(:id))
  end

  def filter(
        _,
        %Ash.Policy.Authorizer{
          resource: Canary.Accounts.Invite,
          actor: %Canary.Accounts.User{email: _}
        },
        _opts
      ) do
    expr(email <= ^actor(:email))
  end
end

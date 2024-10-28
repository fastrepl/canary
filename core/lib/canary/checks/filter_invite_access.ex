defmodule Canary.Checks.Filter.InviteAccess do
  use Ash.Policy.FilterCheck

  @impl true
  def describe(_) do
    "actor has correct access to invite"
  end

  @impl true
  def filter(%Canary.Accounts.Account{id: _}, %Ash.Policy.Authorizer{} = _authorizer, _opts) do
    expr(account_id == ^actor(:id))
  end

  def filter(%Canary.Accounts.User{email: _}, %Ash.Policy.Authorizer{} = _authorizer, _opts) do
    expr(email == ^actor(:email))
  end

  def filter(_actor, _authorizer, _opts), do: false
end

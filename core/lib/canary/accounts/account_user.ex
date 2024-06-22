defmodule Canary.Accounts.AccountUser do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  relationships do
    belongs_to :user, Canary.Accounts.User, primary_key?: true, allow_nil?: false
    belongs_to :account, Canary.Accounts.Account, primary_key?: true, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  postgres do
    table "account_users"
    repo Canary.Repo
  end
end

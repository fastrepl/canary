defmodule Canary.Accounts.Invite do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :email, :string, allow_nil?: false
  end

  relationships do
    belongs_to :user, Canary.Accounts.User, allow_nil?: false
    belongs_to :account, Canary.Accounts.Account, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy]

    read :verify do
      argument :id, :uuid, allow_nil?: false
      argument :email, :string, allow_nil?: false

      get? true
      filter expr(id == ^arg(:id))
      filter expr(email == ^arg(:email))
      filter expr(created_at > ago(30, :minute))
    end

    create :create do
      argument :user, :map, allow_nil?: false
      argument :account, :map, allow_nil?: false
      argument :email, :string, allow_nil?: false

      change set_attribute(:email, expr(^arg(:email)))
      change manage_relationship(:user, :user, type: :append)
      change manage_relationship(:account, :account, type: :append)
    end
  end

  postgres do
    table "account_invites"
    repo Canary.Repo
  end
end

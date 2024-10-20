defmodule Canary.Accounts.Account do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer,
    simple_notifiers: [Canary.Notifiers.Discord]

  attributes do
    uuid_primary_key :id
    attribute :super_user, :boolean, default: false
  end

  relationships do
    has_one :billing, Canary.Accounts.Billing
    has_many :projects, Canary.Accounts.Project

    has_one :owner, Canary.Accounts.User

    many_to_many :users, Canary.Accounts.User do
      through Canary.Accounts.AccountUser
    end
  end

  actions do
    defaults [:read, :destroy, update: [:super_user]]

    create :create do
      primary? true
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :owner, type: :append)
      change manage_relationship(:user_id, :users, type: :append)
    end

    update :add_member do
      require_atomic? false
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :users, type: :append)
    end

    update :remove_member do
      require_atomic? false
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :users, type: :remove)
    end
  end

  changes do
    change Canary.Accounts.Changes.InitBilling, on: [:create]
  end

  aggregates do
    count :num_projects, :projects
    count :num_members, :users
  end

  code_interface do
    define :add_member, args: [:user_id], action: :add_member
    define :remove_member, args: [:user_id], action: :remove_member
  end

  postgres do
    table "accounts"
    repo Canary.Repo
  end
end

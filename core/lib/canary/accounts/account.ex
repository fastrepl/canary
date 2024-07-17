defmodule Canary.Accounts.Account do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
  end

  relationships do
    many_to_many :users, Canary.Accounts.User do
      through Canary.Accounts.AccountUser
    end

    has_many :sources, Canary.Sources.Source
    has_many :clients, Canary.Interactions.Client
    has_many :sessions, Canary.Interactions.Session

    has_one :github_app, Canary.Github.App
    has_one :billing, Canary.Accounts.Billing
  end

  actions do
    defaults [:read]

    create :create do
      argument :user, :map, allow_nil?: false
      argument :name, :string, allow_nil?: false

      change manage_relationship(:user, :users, type: :append)
      change set_attribute(:name, expr(^arg(:name)))
    end

    update :add_member do
      require_atomic? false
      argument :user, :map, allow_nil?: false

      change manage_relationship(:user, :users, type: :append)
      change Canary.Accounts.Changes.StripeReportSeat
    end

    update :remove_member do
      require_atomic? false
      argument :user, :map, allow_nil?: false

      change manage_relationship(:user, :users, type: :remove)
      change Canary.Accounts.Changes.StripeReportSeat
    end

    update :update_name do
      argument :name, :string, allow_nil?: false
      change set_attribute(:name, expr(^arg(:name)))
    end
  end

  changes do
    change Canary.Accounts.Changes.InitBilling, on: [:create]
  end

  code_interface do
    define :update_name, args: [:name], action: :update_name
    define :add_member, args: [:user], action: :add_member
    define :remove_member, args: [:user], action: :remove_member
  end

  postgres do
    table "accounts"
    repo Canary.Repo
  end
end

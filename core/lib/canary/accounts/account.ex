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

    has_one :github_app, Canary.Github.App
    has_one :source, Canary.Sources.Source
    has_many :sessions, Canary.Interactions.Session

    has_one :usage, Canary.Accounts.Usage
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
  end

  changes do
    change Canary.Accounts.Changes.InitUsage, on: [:create]
    change Canary.Accounts.Changes.InitBilling, on: [:create]
  end

  postgres do
    table "accounts"
    repo Canary.Repo
  end
end

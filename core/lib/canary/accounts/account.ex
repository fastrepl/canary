defmodule Canary.Accounts.Account do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
  end

  relationships do
    has_one :github_app, Canary.Github.App
    has_one :billing, Canary.Accounts.Billing
    has_one :subdomain, Canary.Accounts.Subdomain

    has_many :sources, Canary.Sources.Source
    has_many :keys, Canary.Accounts.Key

    many_to_many :users, Canary.Accounts.User do
      through Canary.Accounts.AccountUser
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :users, type: :append)
      change set_attribute(:name, "account_#{Ash.UUID.generate() |> String.slice(0..7)}")
    end

    update :add_member do
      require_atomic? false
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :users, type: :append)
      change Canary.Accounts.Changes.StripeReportSeat
    end

    update :remove_member do
      require_atomic? false
      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :users, type: :remove)
      change Canary.Accounts.Changes.StripeReportSeat
    end

    update :update_name do
      accept [:name]
    end
  end

  changes do
    change Canary.Accounts.Changes.InitBilling, on: [:create]
  end

  code_interface do
    define :update_name, args: [:name], action: :update_name
    define :add_member, args: [:user_id], action: :add_member
    define :remove_member, args: [:user_id], action: :remove_member
  end

  postgres do
    table "accounts"
    repo Canary.Repo
  end
end

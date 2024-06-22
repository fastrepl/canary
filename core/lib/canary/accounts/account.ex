defmodule Canary.Accounts.Account do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :user_id, :uuid do
      allow_nil? false
    end

    attribute :name, :string do
      allow_nil? false
    end
  end

  relationships do
    many_to_many :users, Canary.Accounts.User do
      through Canary.Accounts.AccountUser
    end

    has_many :source_websites, Canary.Sources.Website
    has_many :client_websites, Canary.Clients.Website
  end

  actions do
    create :create do
      accept [:user_id, :name]
    end

    update :update do
      accept [:name]
    end
  end

  postgres do
    table "accounts"
    repo Canary.Repo
  end
end

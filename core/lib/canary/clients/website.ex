defmodule Canary.Clients.Website do
  use Ash.Resource,
    domain: Canary.Clients,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :account_id, :uuid do
      allow_nil? false
    end

    attribute :base_url, :string do
      allow_nil? false
    end

    attribute :public_key, :string do
      allow_nil? false
      default &Ash.UUID.generate/0
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:base_url, :account_id]
      change set_attribute(:public_key, Ash.UUID.generate())
    end
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  postgres do
    table "client_websites"
    repo Canary.Repo
  end
end

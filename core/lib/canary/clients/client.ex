defmodule Canary.Clients.Client do
  use Ash.Resource,
    domain: Canary.Clients,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :account_id, :uuid do
      allow_nil? false
    end

    attribute :type, :atom, constraints: [one_of: [:web]]

    attribute :web_base_url, :string
    attribute :web_public_key, :string, default: &Ash.UUID.generate/0
  end

  actions do
    defaults [:read, :destroy]

    create :create_web do
      argument :account_id, :uuid do
        allow_nil? false
      end

      argument :web_base_url, :string do
        allow_nil? false
      end

      change set_attribute(:type, :web)
    end
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  postgres do
    table "clients"
    repo Canary.Repo
  end
end

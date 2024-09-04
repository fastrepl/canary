defmodule Canary.Accounts.Subdomain do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :host, :string, allow_nil?: false
  end

  identities do
    identity :unique_name, [:name]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [:name, :host]
      argument :account_id, :uuid, allow_nil?: false

      change manage_relationship(:account_id, :account, type: :append)
      change {Canary.Change.AddCert, host_attribute: :host}
    end

    destroy :destroy do
      primary? true

      change {Canary.Change.RemoveCert, host_attribute: :host}
    end
  end

  postgres do
    table "account_subdomains"
    repo Canary.Repo
  end
end

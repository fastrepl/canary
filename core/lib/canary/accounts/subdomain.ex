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
    identity :unique_host, [:host]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  actions do
    defaults [:read]

    read :find_by_name do
      get? true

      argument :name, :string, allow_nil?: false
      filter expr(name == ^arg(:name))
      prepare build(load: [:account])
    end

    read :find_by_host do
      get? true

      argument :host, :string, allow_nil?: false
      filter expr(host == ^arg(:host))
      prepare build(load: [:account])
    end

    create :create do
      primary? true

      accept [:name, :host]
      argument :account_id, :uuid, allow_nil?: false

      change manage_relationship(:account_id, :account, type: :append)

      if Application.compile_env(:canary, :env) == :prod do
        change {Canary.Change.AddCert, host_attribute: :host}
      end
    end

    destroy :destroy do
      primary? true

      if Application.compile_env(:canary, :env) == :prod do
        change {Canary.Change.RemoveCert, host_attribute: :host}
      end
    end
  end

  code_interface do
    define :find_by_name, args: [:name], action: :find_by_name
    define :find_by_host, args: [:host], action: :find_by_host
  end

  postgres do
    table "account_subdomains"
    repo Canary.Repo
  end
end

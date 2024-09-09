defmodule Canary.Accounts.Key do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :value, :string, allow_nil?: false
    attribute :config, Canary.Type.KeyConfig, allow_nil?: false
  end

  identities do
    identity :unique_value, [:value]
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  actions do
    defaults [:read, :destroy]

    read :find do
      get? true

      argument :value, :string, allow_nil?: false
      filter expr(value == ^arg(:value))
      prepare build(load: [account: [:sources]])
    end

    create :create do
      primary? true

      accept [:value, :config]
      argument :account_id, :uuid, allow_nil?: false

      change manage_relationship(:account_id, :account, type: :append)

      change {
        Canary.Change.GenerateKey,
        length: 32, output_attribute: :value
      }
    end
  end

  code_interface do
    define :find, args: [:value], action: :find
  end

  postgres do
    table "account_keys"
    repo Canary.Repo
  end
end

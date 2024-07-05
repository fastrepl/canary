defmodule Canary.Accounts.Usage do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :generation, :integer, default: 0
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account
  end

  actions do
    defaults [:read]

    create :create do
      argument :account, :map, allow_nil?: false
      change manage_relationship(:account, :account, type: :append)
    end

    update :increment_generation do
      change atomic_update(:generation, expr(generation + 1))
    end

    update :reset do
      change set_attribute(:generation, 0)
    end
  end

  postgres do
    table "usages"
    repo Canary.Repo
  end
end

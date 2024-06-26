defmodule Canary.Accounts.Account do
  use Ash.Resource,
    domain: Canary.Accounts,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end
  end

  relationships do
    many_to_many :users, Canary.Accounts.User do
      through Canary.Accounts.AccountUser
    end

    has_many :sources, Canary.Sources.Source
  end

  actions do
    defaults [:read]

    create :create do
      argument :user, :map, allow_nil?: false
      argument :name, :string, allow_nil?: false

      change manage_relationship(:user, :users, type: :append)
      change set_attribute(:name, expr(^arg(:name)))
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

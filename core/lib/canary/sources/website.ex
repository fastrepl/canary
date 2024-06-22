defmodule Canary.Sources.Website do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :account_id, :uuid do
      allow_nil? false
    end

    attribute :base_url, :string do
      allow_nil? false
    end
  end

  actions do
    defaults [:destroy]

    create :create do
      accept [:base_url, :account_id]
    end
  end

  relationships do
    belongs_to :account, Canary.Accounts.Account

    has_many :snapshots, Canary.Sources.Snapshot do
      destination_attribute :source_id
    end
  end

  postgres do
    table "source_websites"
    repo Canary.Repo
  end
end

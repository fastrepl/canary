defmodule Canary.Sources.Snapshot do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :source_id, :uuid do
      allow_nil? false
    end

    create_timestamp :created_at
  end

  relationships do
    has_many :documents, Canary.Sources.Document
  end

  postgres do
    table "source_snapshots"
    repo Canary.Repo
  end
end

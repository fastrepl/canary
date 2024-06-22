defmodule Canary.Sources.Document do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    integer_primary_key :id

    attribute :content, :string
    attribute :embedding, :vector
  end

  relationships do
    belongs_to :snapshot, Canary.Sources.Snapshot
  end

  actions do
    create :create do
      accept [:content, :embedding]
    end
  end

  postgres do
    table "source_documents"
    repo Canary.Repo
  end
end

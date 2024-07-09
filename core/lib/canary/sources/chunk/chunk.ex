defmodule Canary.Sources.Chunk do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  @embedding_dimensions 384

  attributes do
    integer_primary_key :id

    attribute :content, :string, allow_nil?: false
    attribute :embedding, :vector, allow_nil?: false
    attribute :url, :string, allow_nil?: true
  end

  relationships do
    belongs_to :document, Canary.Sources.Document
  end

  actions do
    defaults [:read]

    create :create do
      argument :document, :map, allow_nil?: false
      argument :content, :string, allow_nil?: false
      argument :embedding, :vector, allow_nil?: false

      change manage_relationship(:document, :document, type: :append)
      change set_attribute(:content, expr(^arg(:content)))
      change set_attribute(:embedding, expr(^arg(:embedding)))
    end

    read :fts_search do
      argument :text, :string, allow_nil?: false

      manual Canary.Sources.Chunk.Search.fts()
    end

    read :hybrid_search do
      argument :text, :string, allow_nil?: false
      argument :embedding, :vector, allow_nil?: false
      argument :threshold, :float, allow_nil?: true

      manual Canary.Sources.Chunk.Search.hydrid()
    end
  end

  code_interface do
    define :fts_search,
      args: [:text],
      action: :fts_search

    define :hybrid_search,
      args: [:text, :embedding, {:optional, :threshold}],
      action: :hybrid_search
  end

  json_api do
    type "chunk"

    routes do
      post(:fts_search, route: "/search/fts")
      post(:hybrid_search, route: "/search/hybrid")
    end
  end

  postgres do
    table "chunks"
    repo Canary.Repo

    migration_types embedding: {:vector, @embedding_dimensions}

    references do
      reference :document, on_delete: :delete
    end
  end
end

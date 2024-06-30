defmodule Canary.Sources.Document do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  attributes do
    uuid_primary_key :id, public?: true
    create_timestamp :created_at, public?: true

    attribute :url, :string, allow_nil?: true, public?: true
    attribute :content_hash, :binary, allow_nil?: false
  end

  identities do
    identity :unique_content, [:content_hash]
  end

  relationships do
    belongs_to :source, Canary.Sources.Source
    has_many :chunks, Canary.Sources.Chunk
  end

  actions do
    defaults [:read, :destroy]

    read :find do
      argument :url, :string, allow_nil?: true
      argument :content_hash, :string, allow_nil?: false

      get? true
      filter expr(url == ^arg(:url) and content_hash == ^arg(:content_hash))
    end

    create :ingest_text do
      transaction? true

      argument :url, :string, allow_nil?: true
      argument :source, :map, allow_nil?: false
      argument :content, :string, allow_nil?: false

      change set_attribute(:url, expr(^arg(:url)))
      change manage_relationship(:source, :source, type: :append)

      change {
        Canary.Sources.Changes.Hash,
        source_attr: :content, hash_attr: :content_hash
      }

      change Canary.Sources.Changes.CreateChunksFromDocument
    end
  end

  code_interface do
    define :ingest_text, args: [:source, :content, {:optional, :url}], action: :ingest_text
  end

  json_api do
    type "document"

    routes do
      get(:read, route: "documents/:id")
      delete(:destroy, route: "documents/:id")
      post(:ingest_text, route: "documents/text")
    end
  end

  postgres do
    table "source_documents"
    repo Canary.Repo

    references do
      reference :source, on_delete: :delete
    end
  end
end

defmodule Canary.Sources.Document do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    update_timestamp :updated_at

    attribute :index_id, :integer, allow_nil?: true
    attribute :url, :string, allow_nil?: false
    attribute :hash, :binary, allow_nil?: false
  end

  identities do
    identity :unique_url, [:url]
  end

  relationships do
    belongs_to :source, Canary.Sources.Source
  end

  actions do
    defaults [:read]

    read :search do
      argument :source, :uuid, allow_nil?: false
      argument :query, :string, allow_nil?: false
      manual Canary.Sources.Document.Search
    end

    create :create do
      primary? true

      argument :source, :uuid, allow_nil?: false
      argument :title, :string, allow_nil?: false
      argument :url, :string, allow_nil?: false
      argument :content, :string, allow_nil?: false
      argument :tags, {:array, :string}, default: []

      change manage_relationship(:source, :source, type: :append)
      change set_attribute(:url, expr(^arg(:url)))

      change {
        Canary.Sources.Changes.Hash,
        source_attrs: [:title, :content, :tags], hash_attr: :hash
      }

      change {
        Canary.Sources.Changes.Index.Insert,
        source_attrs: [:title, :content, :tags, :source], result_attr: :index_id
      }
    end

    update :update do
      primary? true
    end

    destroy :destroy do
      primary? true
      require_atomic? false

      change {
        Canary.Sources.Changes.Index.Destroy,
        result_attr: :index_id
      }
    end
  end

  postgres do
    table "documents"
    repo Canary.Repo
  end
end

defmodule Canary.Sources.Document.Search do
  use Ash.Resource.ManualRead

  def read(ash_query, _ecto_query, _opts, _context) do
    source = ash_query.arguments.source
    query = ash_query.arguments.query
    Canary.Index.Document.search(source, query)
  end
end

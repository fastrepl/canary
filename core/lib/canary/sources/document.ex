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
    identity :unique_document, [:source_id, :url]
  end

  relationships do
    belongs_to :source, Canary.Sources.Source
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      argument :source, :uuid, allow_nil?: false
      argument :url, :string, allow_nil?: false
      argument :title, :string, allow_nil?: false
      argument :content, :string, allow_nil?: false
      argument :tags, {:array, :string}, default: []

      change manage_relationship(:source, :source, type: :append)
      change set_attribute(:url, expr(^arg(:url)))

      change {
        Canary.Sources.Changes.Hash,
        source_attrs: [:title, :content, :tags], hash_attr: :hash
      }

      change {
        Canary.Sources.Changes.Typesense.Insert,
        result_attr: :index_id,
        source_arg: :source,
        title_arg: :title,
        content_arg: :content,
        tags_arg: :tags,
        url_arg: :url
      }
    end

    destroy :destroy do
      primary? true
      require_atomic? false

      change {Canary.Sources.Changes.Typesense.Destroy, id_attr: :index_id}
    end
  end

  code_interface do
    define :destroy, args: [], action: :destroy
  end

  postgres do
    table "documents"
    repo Canary.Repo
  end
end

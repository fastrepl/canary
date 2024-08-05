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
    attribute :summary, :string, allow_nil?: true
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
      argument :title, :string, allow_nil?: false
      argument :titles, {:array, :string}, default: []
      argument :url, :string, allow_nil?: false
      argument :content, :string, allow_nil?: false
      argument :tags, {:array, :string}, default: []
      argument :summary, :string, allow_nil?: true

      change manage_relationship(:source, :source, type: :append)
      change set_attribute(:url, expr(^arg(:url)))
      change set_attribute(:summary, expr(^arg(:summary)))

      change {
        Canary.Sources.Changes.Hash,
        source_attrs: [:title, :titles, :content, :tags], hash_attr: :hash
      }

      change {
        Canary.Sources.Changes.Index.Insert,
        index_id_attr: :index_id,
        source_arg: :source,
        title_arg: :title,
        titles_arg: :titles,
        content_arg: :content,
        tags_arg: :tags,
        url_arg: :url
      }
    end

    destroy :destroy do
      primary? true

      change {
        Canary.Sources.Changes.Index.Destroy,
        index_id_attr: :index_id
      }
    end

    update :update_summary do
      argument :summary, :string, allow_nil?: false
      change set_attribute(:summary, expr(^arg(:summary)))
    end
  end

  code_interface do
    define :destroy, args: [], action: :destroy
    define :update_summary, args: [:summary], action: :update_summary
  end

  postgres do
    table "documents"
    repo Canary.Repo
  end
end

defmodule Canary.Sources.Document do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :index_id, :uuid, allow_nil?: false
    attribute :parent_index_id, :string, allow_nil?: true

    attribute :meta, Canary.Type.DocumentMeta, allow_nil?: false
    attribute :chunks, {:array, Canary.Sources.Chunk}, allow_nil?: false
  end

  relationships do
    belongs_to :source, Canary.Sources.Source, allow_nil?: false
  end

  actions do
    defaults [:read, update: [:meta, :chunks]]

    create :create do
      primary? true

      argument :source_id, :uuid, allow_nil?: false
      argument :fetcher_result, :map, allow_nil?: false

      change manage_relationship(:source_id, :source, type: :append)

      change {
        Canary.Sources.Document.Create,
        source_id_argument: :source_id,
        data_argument: :fetcher_result,
        meta_attribute: :meta,
        chunks_attribute: :chunks,
        tracking_id_attribute: :index_id,
        parent_tracking_id_attribute: :parent_index_id
      }
    end

    destroy :destroy do
      primary? true
      require_atomic? false

      change {
        Canary.Index.Trieve.Changes.DeleteGroup,
        tracking_id_attribute: :index_id, parent_tracking_id_attribute: :parent_index_id
      }
    end
  end

  code_interface do
    define :update_chunks, args: [:chunks], action: :update
    define :update, args: [:meta, :chunks], action: :update
  end

  postgres do
    table "documents"
    repo Canary.Repo

    references do
      reference :source, deferrable: :initially
    end
  end
end

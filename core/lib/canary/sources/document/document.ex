defmodule Canary.Sources.Document do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at

    attribute :meta, Canary.Type.DocumentMeta, allow_nil?: false
    attribute :chunks, {:array, Canary.Type.DocumentChunk}, allow_nil?: false
  end

  relationships do
    belongs_to :source, Canary.Sources.Source
  end

  actions do
    defaults [:read, update: [:meta, :chunks]]

    read :find_by_chunk_index_ids do
      argument :chunk_index_ids, {:array, :uuid}, allow_nil?: false

      filter expr(
               fragment(
                 "EXISTS (SELECT 1 FROM unnest(chunks) AS chunk WHERE (chunk->'value'->>'index_id')::text = ANY(?))",
                 ^arg(:chunk_index_ids)
               )
             )

      prepare build(select: [:meta])
    end

    create :create_webpage do
      argument :source_id, :uuid, allow_nil?: false
      argument :fetcher_result, :map, allow_nil?: false

      change manage_relationship(:source_id, :source, type: :append)

      change {
        Canary.Sources.Document.CreateWebpage,
        source_id_argument: :source_id,
        fetcher_result_argument: :fetcher_result,
        meta_attribute: :meta,
        chunks_attribute: :chunks
      }
    end

    create :create_openapi do
      argument :source_id, :uuid, allow_nil?: false
      argument :fetcher_result, :map, allow_nil?: false

      change manage_relationship(:source_id, :source, type: :append)

      change {
        Canary.Sources.Document.CreateOpenAPI,
        source_id_argument: :source_id,
        fetcher_result_argument: :fetcher_result,
        chunks_attribute: :chunks,
        meta_attribute: :meta
      }
    end

    create :create_github_issue do
      argument :source_id, :uuid, allow_nil?: false
      argument :fetcher_results, {:array, :map}, allow_nil?: false

      change manage_relationship(:source_id, :source, type: :append)

      change {
        Canary.Sources.Document.CreateGithubIssue,
        source_id_argument: :source_id,
        fetcher_results_argument: :fetcher_results,
        meta_attribute: :meta,
        chunks_attribute: :chunks
      }
    end

    create :create_github_discussion do
      argument :source_id, :uuid, allow_nil?: false
      argument :fetcher_results, {:array, :map}, allow_nil?: false

      change manage_relationship(:source_id, :source, type: :append)

      change {
        Canary.Sources.Document.CreateGithubDiscussion,
        source_id_argument: :source_id,
        fetcher_results_argument: :fetcher_results,
        meta_attribute: :meta,
        chunks_attribute: :chunks
      }
    end

    destroy :destroy do
      primary? true

      change {Canary.Change.CascadeDestroy, attribute: :chunks}
    end
  end

  code_interface do
    define :update_chunks, args: [:chunks], action: :update
    define :update, args: [:meta, :chunks], action: :update
    define :find_by_chunk_index_ids, args: [:chunk_index_ids], action: :find_by_chunk_index_ids
  end

  postgres do
    table "documents"
    repo Canary.Repo

    references do
      reference :source, deferrable: :initially
    end
  end
end

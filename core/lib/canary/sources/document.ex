defmodule Canary.Sources.Document do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id, public?: true
    create_timestamp :created_at, public?: true

    attribute :url, :string, allow_nil?: false, public?: true
    attribute :title, :string, allow_nil?: true, public?: true
    attribute :content_hash, :binary, allow_nil?: false
  end

  identities do
    identity :unique_content, [:url, :content_hash]
  end

  relationships do
    belongs_to :source, Canary.Sources.Source
    has_many :chunks, Canary.Sources.Chunk
  end

  actions do
    defaults [:read, :destroy]

    read :find do
      argument :source_id, :uuid, allow_nil?: false
      argument :url, :string, allow_nil?: false
      argument :content_hash, :string, allow_nil?: false

      get? true
      filter expr(source_id == ^arg(:source_id))
      filter expr(url == ^arg(:url))
      filter expr(content_hash == ^arg(:content_hash))
    end

    create :ingest_text do
      transaction? true

      argument :source, :map, allow_nil?: false
      argument :url, :string, allow_nil?: false
      argument :title, :string, allow_nil?: true
      argument :content, :string, allow_nil?: false

      change manage_relationship(:source, :source, type: :append)
      change set_attribute(:title, expr(^arg(:title)))
      change set_attribute(:url, expr(^arg(:url)))

      change {
        Canary.Sources.Changes.Hash,
        source_attr: :content, hash_attr: :content_hash
      }

      change Canary.Sources.Changes.CreateChunksFromDocument
    end
  end

  code_interface do
    define :ingest_text,
      args: [:source, :url, :title, :content],
      action: :ingest_text
  end

  postgres do
    table "documents"
    repo Canary.Repo

    references do
      reference :source, on_delete: :delete
    end
  end
end

defmodule Canary.Sources.Document.HybridSearch do
  use Ash.Resource.ManualRead

  @index_name "search_index"
  @table_name "documents"
  @table_text_field "content"
  @table_vector_field "content_embedding"

  def read(ash_query, _ecto_query, _opts, _context) do
    text = ash_query.arguments.text
    embedding = ash_query.arguments.embedding

    opts = [
      threshold: ash_query.arguments[:threshold],
      limit: ash_query.limit
    ]

    hybrid_search(text, embedding, opts)
  end

  defp hybrid_search(text, embedding, opts) do
    n = opts[:limit] || 10
    threshold = opts[:threshold] || 0.4

    embedding =
      embedding
      |> Ash.Vector.to_list()
      |> Jason.encode!()

    """
    SELECT doc.*
    FROM #{@table_name} doc
    LEFT JOIN (
      SELECT *
      FROM #{@index_name}.rank_hybrid(
        bm25_query => $1,
        similarity_query => $2,
        bm25_weight => 0.2,
        bm25_limit_n => 100,
        similarity_weight => 0.8,
        similarity_limit_n => 100
      )
    ) index
    ON doc.id = index.id
    WHERE index.rank_hybrid >= $3
    ORDER BY index.rank_hybrid DESC
    LIMIT $4;
    """
    |> query([
      ~s(#{@table_text_field}:"#{text}"),
      ~s('#{embedding}' <-> #{@table_vector_field}),
      threshold,
      n
    ])
  end

  defp query(query, params) do
    query
    |> Canary.Repo.query(params)
    |> case do
      {:ok, %{rows: rows, columns: columns}} ->
        docs = rows |> Enum.map(&Canary.Repo.load(Canary.Sources.Document, {columns, &1}))
        {:ok, docs}

      error ->
        error
    end
  end
end

defmodule Canary.Sources.Document.Migration do
  use Ecto.Migration

  @index_name "search_index"
  @table_name "documents"
  @table_vector_field "content_embedding"
  @table_id_field "id"
  @distance_metric "vector_cosine_ops"

  def up do
    hnsw_up()
    bm25_up()
  end

  def down do
    hnsw_down()
    bm25_down()
  end

  defp hnsw_up() do
    execute("""
    CREATE INDEX ON #{@table_name}
    USING hnsw (#{@table_vector_field} #{@distance_metric});
    """)
  end

  defp hnsw_down() do
    execute("""
    DROP INDEX #{@table_name};
    """)
  end

  defp bm25_up() do
    execute("""
    CALL paradedb.create_bm25(
      index_name => '#{@index_name}',
      table_name => '#{@table_name}',
      key_field => '#{@table_id_field}',
      text_fields => '#{Jason.encode!(%{content: %{tokenizer: %{type: "ngram", min_gram: 4, max_gram: 6, prefix_only: true}}})}'
    );
    """)
  end

  defp bm25_down() do
    execute("""
    CALL paradedb.drop_bm25('#{@table_name}');
    """)
  end
end

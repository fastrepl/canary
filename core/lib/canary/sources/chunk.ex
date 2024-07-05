defmodule Canary.Sources.Chunk do
  use Ash.Resource,
    domain: Canary.Sources,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  @embedding_dimensions 384

  attributes do
    uuid_primary_key :id

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

    read :search do
      argument :text, :string, allow_nil?: false
      argument :embedding, :vector, allow_nil?: false
      argument :threshold, :float, allow_nil?: true

      manual Canary.Sources.Chunk.HybridSearch
    end
  end

  code_interface do
    define :search, args: [:text, :embedding, {:optional, :threshold}], action: :search
  end

  json_api do
    type "chunk"

    routes do
      post(:search, route: "/search")
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

defmodule Canary.Sources.Chunk.HybridSearch do
  use Ash.Resource.ManualRead

  @index_name "search_index"
  @table_name "chunks"
  @table_text_field "content"
  @table_vector_field "embedding"

  def read(ash_query, _ecto_query, _opts, _context) do
    text = ash_query.arguments.text
    embedding = ash_query.arguments.embedding

    opts = [
      threshold: ash_query.arguments[:threshold],
      limit: ash_query.limit
    ]

    run(text, embedding, opts)
  end

  defp run(text, embedding, opts) do
    n = opts[:limit] || 10
    threshold = opts[:threshold] || 0

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
        bm25_weight => 0.5,
        bm25_limit_n => 100,
        similarity_weight => 0.5,
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
        docs = rows |> Enum.map(&Canary.Repo.load(Canary.Sources.Chunk, {columns, &1}))
        {:ok, docs}

      error ->
        error
    end
  end
end

defmodule Canary.Sources.Chunk.Migration do
  use Ecto.Migration

  @index_name "search_index"
  @table_name "chunks"
  @table_vector_field "embedding"
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

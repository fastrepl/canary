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

    read :hybrid_search do
      argument :text, :string do
        allow_nil? false
      end

      argument :embedding, :vector do
        allow_nil? false
      end

      argument :threshold, :float do
        allow_nil? true
      end

      manual Canary.Sources.Document.HybridSearch
    end
  end

  postgres do
    table "source_documents"
    repo Canary.Repo
  end
end

defmodule Canary.Sources.Document.HybridSearch do
  use Ash.Resource.ManualRead

  @index_name "search_index"
  @table_name "source_documents"
  @table_text_field "content"
  @table_vector_field "embedding"

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
        bm25_weight => 0.6,
        bm25_limit_n => 100,
        similarity_weight => 0.4,
        similarity_limit_n => 100
      )
    ) index
    ON doc.id = index.id
    WHERE index.rank_hybrid >= $3
    ORDER BY index.rank_hybrid DESC
    LIMIT $4;
    """
    |> query([
      "#{@table_text_field}:#{text}",
      "'#{embedding}' <-> #{@table_vector_field}",
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
  @table_name "source_documents"
  @table_id_field "id"

  def up do
    execute("""
    CALL paradedb.create_bm25(
      index_name => '#{@index_name}',
      table_name => '#{@table_name}',
      key_field => '#{@table_id_field}',
      text_fields => '#{Jason.encode!(%{content: %{tokenizer: %{type: "ngram", min_gram: 4, max_gram: 6, prefix_only: true}}})}'
    );
    """)
  end

  def down do
    execute("""
    CALL paradedb.drop_bm25('#{@table_name}');
    """)
  end
end

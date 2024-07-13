defmodule Canary.Sources.Chunk.Migration do
  use Ecto.Migration

  @index_name "search_index"
  @distance_metric "vector_cosine_ops"

  @table_name "chunks"
  @table_id_field "id"
  @table_vector_field "embedding"
  @table_content_field "content"

  defp index_config() do
    %{
      @table_content_field => %{
        tokenizer: %{type: "ngram", min_gram: 2, max_gram: 6, prefix_only: false},
        normalizer: "lowercase"
      }
    }
  end

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
      text_fields => '#{Jason.encode!(index_config())}'
    );
    """)
  end

  defp bm25_down() do
    execute("""
    CALL paradedb.drop_bm25('#{@table_name}');
    """)
  end
end

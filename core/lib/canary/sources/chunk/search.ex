defmodule Canary.Sources.Chunk.Search do
  def fts(), do: Canary.Sources.Chunk.FTS
  def hydrid(), do: Canary.Sources.Chunk.Hybrid

  def query(query, params) do
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

defmodule Canary.Sources.Chunk.FTS do
  use Ash.Resource.ManualRead

  @index_name "search_index"
  @table_text_field "content"

  def read(ash_query, _ecto_query, _opts, _context) do
    text = ash_query.arguments.text
    run(text, [])
  end

  defp run(text, _opts) do
    query = """
    SELECT paradedb.highlight(doc.id, $1, '<mark>', '</mark>'), doc.*
    FROM #{@index_name}.search($2) doc
    """

    params = [
      @table_text_field,
      ~s(#{@table_text_field}:"#{text}")
    ]

    query
    |> Canary.Repo.query(params)
    |> case do
      {:ok, %{rows: rows, columns: [_ | columns]}} ->
        rows =
          rows
          |> Enum.map(fn [highlight | row] ->
            {highlight, row}
          end)

        docs =
          rows
          |> Enum.map(fn {highlight, row} ->
            Canary.Sources.Chunk
            |> Canary.Repo.load({columns, row})
            |> Map.put(:content, highlight)
          end)

        {:ok, docs}

      error ->
        error
    end
  end
end

defmodule Canary.Sources.Chunk.Hybrid do
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

    query = """
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

    params = [
      ~s(#{@table_text_field}:"#{text}"),
      ~s('#{embedding}' <-> #{@table_vector_field}),
      threshold,
      n
    ]

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

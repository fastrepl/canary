defmodule Canary.Index do
  @collection "default"

  def create() do
    Typesense.Collections.create_collection(%Typesense.CollectionSchema{
      name: @collection,
      fields: [
        %Typesense.Field{name: "source", type: "string"},
        %Typesense.Field{name: "title", type: "string", stem: true},
        %Typesense.Field{name: "content", type: "string", stem: true},
        %Typesense.Field{name: "tags", type: "string[]"},
        %Typesense.Field{name: "meta", type: "object", index: false}
      ],
      enable_nested_fields: true,
      token_separators: [".", "-", "_"]
    })
  end

  def delete() do
    Typesense.Collections.delete_collection(@collection)
  end
end

defmodule Canary.Index.Document do
  @collection "default"

  def insert(doc) do
    Typesense.Documents.index_document(@collection, doc)
  end

  def batch_insert(docs) do
    result =
      docs
      |> Enum.map(&Jason.encode_to_iodata!/1)
      |> Enum.join("\n")
      |> then(
        &Typesense.Documents.import_documents(
          @collection,
          &1,
          return_id: true,
          action: "upsert"
        )
      )

    case result do
      {:ok, result} -> {:ok, parse_import_result(result)}
      error -> error
    end
  end

  def delete(id) do
    Typesense.Documents.delete_document(@collection, id)
  end

  def batch_delete(ids) do
    opts = [filter_by: "id: [#{Enum.join(ids, ",")}]"]
    Typesense.Documents.delete_documents(@collection, opts)
  end

  def update(doc) do
    {id, doc} = Map.pop!(doc, :id)
    Typesense.Documents.update_document(@collection, id, doc)
  end

  def batch_update(docs) do
    result =
      docs
      |> Enum.map(&Jason.encode_to_iodata!/1)
      |> Enum.join("\n")
      |> then(
        &Typesense.Documents.import_documents(
          @collection,
          &1,
          return_id: true,
          action: "emplace"
        )
      )

    case result do
      {:ok, result} -> {:ok, parse_import_result(result)}
      error -> error
    end
  end

  def search(source, query, tags \\ []) do
    filter_by =
      [
        "source:=#{source}",
        if(tags != []) do
          "tags:=[#{Enum.join(tags, ",")}]"
        end
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" && ")

    opts = [
      q: query,
      query_by: "title,content",
      filter_by: filter_by
    ]

    Typesense.Documents.search_collection(@collection, opts)
  end

  defp parse_import_result(result) when is_binary(result) do
    result
    |> String.split("\n")
    |> Enum.map(&Jason.decode!/1)
  end
end

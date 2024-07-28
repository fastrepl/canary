defmodule Canary.Index do
  @collection "default"

  def create() do
    Typesense.Collections.create_collection(%Typesense.CollectionSchema{
      name: @collection,
      fields: [
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

  def batch_insert(docs) do
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
  end

  def batch_delete(ids) do
    opts = [filter_by: "id: [#{Enum.join(ids, ",")}]"]

    Typesense.Documents.delete_documents(@collection, opts)
  end

  def batch_update(docs) do
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
  end

  def update(doc) do
    {id, doc} = Map.pop!(doc, :id)
    Typesense.Documents.update_document(@collection, id, doc)
  end

  def search(query, tags \\ []) do
    base = [q: query, query_by: "title,content"]
    opts = apply_tag_filter(base, tags)

    Typesense.Documents.search_collection(@collection, opts)
  end

  defp apply_tag_filter(opts, tags) do
    filter_by = "tags:=[#{Enum.join(tags, ",")}]"

    case tags do
      [] -> opts
      nil -> opts
      _ -> Keyword.put(opts, :filter_by, filter_by)
    end
  end
end

defmodule Canary.Typesense.Document do
  @derive Jason.Encoder
  defstruct [:source, :title, :content, :tags, :meta]
end

defmodule Canary.Typesense.DocumentMetadata do
  @derive Jason.Encoder
  defstruct [:url]
end

defmodule Canary.Typesense do
  @collection Application.compile_env!(:canary, [:typesense, :collection])

  def ensure_collection() do
    with {:error, _} <- Typesense.Collections.get_collection(@collection),
         {:error, _} <- create_collection() do
      :error
    else
      _ -> :ok
    end
  end

  def create_collection() do
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

  def delete_collection() do
    Typesense.Collections.delete_collection(@collection)
  end

  def insert_document(doc) do
    Typesense.Documents.index_document(@collection, doc)
  end

  def batch_insert_documents(docs) do
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

  def delete_document(id) do
    Typesense.Documents.delete_document(@collection, id)
  end

  def batch_delete_documents(ids) do
    opts = [filter_by: "id: [#{Enum.join(ids, ",")}]"]
    Typesense.Documents.delete_documents(@collection, opts)
  end

  def update_document(doc) do
    {id, doc} = Map.pop!(doc, :id)
    Typesense.Documents.update_document(@collection, id, doc)
  end

  def batch_update_documents(docs) do
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

  def search_documents(source, query, tags \\ []) do
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
      filter_by: filter_by,
      use_cache: true,
      cache_ttl: 60,
      drop_tokens_threshold: 0,
      exclude_fields: "id,source"
    ]

    case Typesense.Documents.search_collection(@collection, opts) do
      {:ok, %{"hits" => hits}} ->
        hits =
          hits
          |> Enum.map(fn hit ->
            %{
              title: hit["highlight"]["title"]["snippet"] || hit["document"]["title"],
              url: hit["document"]["meta"]["url"],
              excerpt: hit["highlight"]["content"]["snippet"] || hit["document"]["content"],
              tags: hit["document"]["tags"]
            }
          end)

        {:ok, hits}

      {:error, error} ->
        {:error, error}
    end
  end

  def get_document(id) do
    Typesense.Documents.get_document(@collection, id)
  end

  defp parse_import_result(result) when is_binary(result) do
    result
    |> String.split("\n")
    |> Enum.map(&Jason.decode!/1)
  end
end

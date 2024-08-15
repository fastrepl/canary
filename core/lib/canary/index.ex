defmodule Canary.Index.Document do
  @derive Jason.Encoder
  defstruct [:id, :source, :title, :content, :tags, :meta]
end

defmodule Canary.Index.DocumentMetadata do
  @derive Jason.Encoder
  defstruct [:url, :titles]
end

defmodule Canary.Index do
  @collection Application.compile_env!(:canary, [:typesense, :collection])
  @stopwords "default_stopwords"

  def search_documents(source, query, tags \\ []) do
    opts = build_search_opts(source, query, tags)

    case Typesense.Documents.search_collection(@collection, opts) do
      {:ok, result} ->
        hits = Map.get(result, :hits, nil) || result["hits"]
        hits = hits |> Enum.map(&transform_hit/1)
        {:ok, hits}

      {:error, error} ->
        {:error, error}
    end
  end

  def batch_search_documents(_, _, _ \\ [])

  def batch_search_documents(_, [], _), do: {:ok, []}

  def batch_search_documents(source, queries, tags) do
    result =
      Typesense.Documents.multi_search(%Typesense.MultiSearchSearchesParameter{
        searches:
          Enum.map(queries, fn query ->
            struct(
              Typesense.MultiSearchCollectionParameters,
              build_search_opts(source, query, tags) ++ [collection: @collection]
            )
          end)
      })

    case result do
      {:ok, result} ->
        results = Map.get(result, :results, nil) || result["results"]

        hits =
          results
          |> Enum.flat_map(fn %{"hits" => hits} ->
            hits |> Enum.map(&transform_hit/1)
          end)
          |> Enum.dedup_by(& &1.url)

        {:ok, hits}

      error ->
        error
    end
  end

  defp transform_hit(hit) do
    %{
      id: hit["document"]["id"],
      title: hit["highlight"]["title"]["snippet"] || hit["document"]["title"],
      titles: hit["document"]["meta"]["titles"],
      url: hit["document"]["meta"]["url"],
      excerpt: hit["highlight"]["content"]["snippet"] || hit["document"]["content"],
      tags: hit["document"]["tags"],
      content: hit["document"]["content"]
    }
  end

  defp build_search_opts(source, query, tags) do
    filter_by =
      [
        "source:=#{source}",
        if(tags != []) do
          "tags:=[#{Enum.join(tags, ",")}]"
        end
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" && ")

    [
      q: query,
      query_by: "title,content",
      query_by_weights: "3,2",
      filter_by: filter_by,
      sort_by: "_text_match:desc",
      exclude_fields: "source",
      prefix: true,
      prioritize_exact_match: false,
      prioritize_token_position: false,
      prioritize_num_matching_fields: true,
      stopwords: @stopwords
    ]
  end

  def ensure_collection() do
    with {:error, _} <- Typesense.Collections.get_collection(@collection),
         {:error, _} <- create_collection() do
      :error
    else
      _ -> :ok
    end
  end

  def ensure_stopwords() do
    Typesense.Stopwords.upsert_stopwords_set(@stopwords, %Typesense.StopwordsSetUpsertSchema{
      locale: "en",
      stopwords: Canary.Native.stopwords()
    })
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

  def delete_document(id) do
    Typesense.Documents.delete_document(@collection, id)
  end

  def batch_delete_documents(ids) do
    opts = [filter_by: "id: [#{Enum.join(ids, ",")}]"]
    Typesense.Documents.delete_documents(@collection, opts)
  end

  def insert_document(%Canary.Index.Document{} = doc) do
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
      {:ok, result} -> {:ok, parse_jsonl(result)}
      error -> error
    end
  end

  def update_document(%Canary.Index.Document{} = doc) do
    {id, doc} = Map.pop!(doc, :id)
    Typesense.Documents.update_document(@collection, id, doc)
  end

  def list_documents(source_id) do
    opts = [filter_by: "source:#{source_id}"]

    case Typesense.Documents.export_documents(@collection, opts) do
      {:ok, ""} -> {:ok, []}
      {:ok, result} -> {:ok, parse_jsonl(result)}
      error -> error
    end
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
      {:ok, result} -> {:ok, parse_jsonl(result)}
      error -> error
    end
  end

  defp parse_jsonl(result) when is_binary(result) do
    result
    |> String.split("\n")
    |> Enum.map(&Jason.decode!/1)
  end
end

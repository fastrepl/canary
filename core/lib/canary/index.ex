defmodule Canary.Index.DocumentMetadata do
  @derive Jason.Encoder
  defstruct [
    :url,
    :titles
  ]
end

defmodule Canary.Index.Document do
  @derive Jason.Encoder
  defstruct [:id, :source_id, :title, :content, :embedding, :tags, :meta]

  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue
  alias Canary.Sources.GithubDiscussion
  alias Canary.Sources.DiscordThread

  def from(%Webpage.Chunk{} = chunk) do
    meta = %Canary.Index.DocumentMetadata{
      url: chunk.url
    }

    %__MODULE__{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title,
      content: chunk.content,
      tags: [],
      meta: meta
    }
  end

  def from(%GithubIssue.Chunk{} = chunk) do
    meta = %Canary.Index.DocumentMetadata{}

    %__MODULE__{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title,
      content: chunk.content,
      tags: [],
      meta: meta
    }
  end

  def from(%GithubDiscussion.Chunk{} = chunk) do
    meta = %Canary.Index.DocumentMetadata{}

    %__MODULE__{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title,
      content: chunk.content,
      tags: [],
      meta: meta
    }
  end

  def from(%DiscordThread.Chunk{} = chunk) do
    meta = %Canary.Index.DocumentMetadata{
      url:
        "https://discord.com/channels/#{chunk.server_id}/#{chunk.channel_id}/#{chunk.message_id}"
    }

    %__MODULE__{
      id: chunk.index_id,
      source_id: chunk.source_id,
      meta: meta
    }
  end
end

defmodule Canary.Index do
  @collection Application.compile_env!(:canary, [:typesense, :collection])
  @stopwords "default_stopwords"

  def search_documents(source_ids, query, opts \\ []) do
    args = build_search_args(source_ids, query, opts)

    case Typesense.Documents.search_collection(@collection, args) do
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

  def batch_search_documents(source, queries, opts) do
    result =
      Typesense.Documents.multi_search(%Typesense.MultiSearchSearchesParameter{
        searches:
          Enum.map(queries, fn query ->
            struct(
              Typesense.MultiSearchCollectionParameters,
              build_search_args(source, query, opts) ++ [collection: @collection]
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
      content: hit["document"]["content"],
      tokens: hit["document"]["meta"]["tokens"],
      source_id: hit["document"]["source_id"]
    }
  end

  defp build_search_args(source_ids, query, opts) do
    tags = opts[:tags]
    embedding = opts[:embedding]
    embedding_alpha = opts[:embedding_alpha] || 0.3

    filter_by =
      [
        "source_id:=[#{Enum.join(source_ids, ",")}]",
        if(tags != nil and tags != []) do
          "tags:=[#{Enum.join(tags, ",")}]"
        end
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" && ")

    query_by = ["title", "content"] |> Enum.join(",")
    query_by_weights = [3, 2] |> Enum.join(",")

    args = [
      q: query,
      query_by: query_by,
      query_by_weights: query_by_weights,
      filter_by: filter_by,
      sort_by: "_text_match:desc",
      exclude_fields: "embedding",
      prefix: true,
      prioritize_exact_match: false,
      prioritize_token_position: false,
      prioritize_num_matching_fields: true,
      stopwords: @stopwords
    ]

    if embedding do
      args
      |> Keyword.put(
        :vector_query,
        "embedding:([#{Enum.join(embedding, ",")}], alpha: #{embedding_alpha})"
      )
    else
      args
    end
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
        %Typesense.Field{name: "source_id", type: "string"},
        %Typesense.Field{name: "title", type: "string", stem: true},
        %Typesense.Field{name: "content", type: "string", stem: true},
        %Typesense.Field{name: "embedding", type: "float[]", num_dim: 384, optional: true},
        %Typesense.Field{name: "tags", type: "string[]"},
        %Typesense.Field{name: "meta", type: "object", index: false, optional: true}
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

  def list_documents!(source_id \\ nil) do
    {:ok, docs} = list_documents(source_id)
    docs
  end

  def list_documents(source_id \\ nil) do
    opts = if source_id, do: [filter_by: "source_id:#{source_id}"], else: []

    case Typesense.Documents.export_documents(@collection, opts) do
      {:ok, ""} -> {:ok, []}
      {:ok, result} -> {:ok, parse_jsonl(result)}
      error -> error
    end
  end

  def get_document!(id) do
    {:ok, doc} = Typesense.Documents.get_document(@collection, id)
    doc
  end

  def get_document(id) do
    Typesense.Documents.get_document(@collection, id)
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

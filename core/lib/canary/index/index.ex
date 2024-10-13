defmodule Canary.Index do
  alias Canary.Sources.Source
  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue
  alias Canary.Sources.GithubDiscussion

  alias Canary.Index.Client
  alias Canary.Index.Document

  def to_doc(%Webpage.Chunk{} = chunk) do
    meta = %Document.Webpage.Meta{
      url: chunk.url,
      document_id: chunk.document_id,
      is_parent: chunk.is_parent
    }

    tags = chunk.tags || []

    %Document.Webpage{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title || "",
      content: chunk.content || "",
      tags: tags,
      is_empty_tags: tags == [],
      meta: meta
    }
  end

  def to_doc(%GithubIssue.Chunk{} = chunk) do
    meta = %Document.GithubIssue.Meta{
      url: chunk.url,
      document_id: chunk.document_id,
      is_parent: chunk.is_parent
    }

    %Document.GithubIssue{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title || "",
      content: chunk.content || "",
      created_at: DateTime.to_unix(chunk.created_at),
      tags: [],
      is_empty_tags: true,
      meta: meta
    }
  end

  def to_doc(%GithubDiscussion.Chunk{} = chunk) do
    meta = %Document.GithubDiscussion.Meta{
      url: chunk.url,
      document_id: chunk.document_id,
      is_parent: chunk.is_parent
    }

    %Document.GithubDiscussion{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title || "",
      content: chunk.content || "",
      created_at: DateTime.to_unix(chunk.created_at),
      tags: [],
      is_empty_tags: true,
      meta: meta
    }
  end

  def insert_document(%Webpage.Chunk{} = chunk) do
    chunk
    |> to_doc()
    |> then(&Client.index_document(:webpage, &1))
  end

  def insert_document(%GithubIssue.Chunk{} = chunk) do
    chunk
    |> to_doc()
    |> then(&Client.index_document(:github_issue, &1))
  end

  def insert_document(%GithubDiscussion.Chunk{} = chunk) do
    chunk
    |> to_doc()
    |> then(&Client.index_document(:github_discussion, &1))
  end

  def batch_insert_document(docs) when is_list(docs) do
    type =
      case Enum.at(docs, 0) do
        %Webpage.Chunk{} -> :webpage
        %GithubIssue.Chunk{} -> :github_issue
        %GithubDiscussion.Chunk{} -> :github_discussion
      end

    docs
    |> Enum.map(&to_doc/1)
    |> then(&Client.batch_index_document(type, &1))
  end

  def delete_document(source_type, id)
      when source_type in [
             :webpage,
             :github_issue,
             :github_discussion
           ] do
    Client.delete_document(source_type, id)
  end

  def batch_delete_document(source_type, ids)
      when source_type in [
             :webpage,
             :github_issue,
             :github_discussion
           ] do
    Client.batch_delete_document(source_type, ids)
  end

  def search(_, _, _ \\ [])
  def search([], _, _), do: {:ok, []}
  def search(_, [], _), do: {:ok, []}

  def search(sources, queries, opts) when is_list(queries) do
    args = build_args(sources, queries, opts)

    case Canary.Index.Client.multi_search(args) do
      {:ok, %{"results" => results}} ->
        ret =
          results
          |> Enum.reject(fn %{"hits" => hits} -> length(hits) == 0 end)
          |> Enum.map(fn %{"hits" => hits} ->
            hits =
              hits
              |> Enum.map(&transform_hit/1)
              |> Enum.uniq_by(& &1.id)

            source_id = hits |> Enum.at(0) |> Map.get(:source_id)

            %{source_id: source_id, hits: hits}
          end)

        {:ok, ret}

      {:ok, res} ->
        {:error, res}

      {:error, error} ->
        {:error, error}
    end
  end

  defp build_args(sources, queries, opts) do
    for(source <- sources, query <- queries, do: {source, query})
    |> Enum.map(fn {source, query} ->
      %{
        q: query,
        prefix: true,
        sort_by: "_text_match:desc",
        prioritize_exact_match: true,
        prioritize_token_position: true,
        prioritize_num_matching_fields: false,
        max_candidates: 4 * 5,
        min_len_1typo: 3,
        min_len_2typo: 6
      }
      |> add_source_specific(source, opts)
      |> add_stopwords(query)
      |> add_embedding_args(opts)
    end)
  end

  defp add_source_specific(args, %Source{id: id, config: %Ash.Union{type: type}}, opts) do
    tags = opts[:tags]

    highlight_fields = "content"

    filter_by =
      [
        "source_id:=[#{id}]",
        if(tags != nil and tags != []) do
          "(tags:=[#{Enum.join(tags, ",")}] || is_empty_tags:=true)"
        end
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" && ")

    query_by = ["title", "content"] |> Enum.join(",")
    query_by_weights = [3, 1] |> Enum.join(",")

    sort_by =
      case type do
        :webpage -> "_text_match:desc"
        :github_issue -> "_text_match(buckets: 2):desc,created_at:desc"
        :github_discussion -> "_text_match(buckets: 2):desc,created_at:desc"
        _ -> "_text_match:desc"
      end

    args
    |> Map.put(:collection, to_string(type))
    |> Map.put(:sort_by, sort_by)
    |> Map.put(:filter_by, filter_by)
    |> Map.put(:query_by, query_by)
    |> Map.put(:query_by_weights, query_by_weights)
    |> Map.put(:highlight_fields, highlight_fields)
  end

  defp add_stopwords(args, query) do
    if query
       |> String.split(" ")
       |> Enum.filter(&(&1 != ""))
       |> length() < 2 do
      args
    else
      args
      |> Map.put(:stopwords, Canary.Index.Stopword.id())
    end
  end

  defp add_embedding_args(args, opts) do
    embedding = opts[:embedding]
    embedding_alpha = opts[:embedding_alpha] || 0.3

    if embedding do
      args
      |> Map.put(
        :vector_query,
        "embedding:([#{Enum.join(embedding, ",")}], alpha: #{embedding_alpha})"
      )
    else
      args
    end
  end

  defp transform_hit(hit) do
    %{
      id: hit["document"]["id"],
      document_id: hit["document"]["meta"]["document_id"],
      source_id: hit["document"]["source_id"],
      url: hit["document"]["meta"]["url"],
      title: hit["document"]["title"],
      excerpt: hit["highlight"]["content"]["snippet"] || hit["document"]["content"],
      tags: hit["document"]["tags"],
      is_parent: hit["document"]["meta"]["is_parent"]
    }
  end
end

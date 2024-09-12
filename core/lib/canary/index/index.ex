defmodule Canary.Index do
  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue
  alias Canary.Sources.GithubDiscussion

  alias Canary.Index.Client
  alias Canary.Index.Document

  def insert_document(%Webpage.Chunk{} = chunk) do
    meta = %Document.Webpage.Meta{
      url: chunk.url
    }

    doc = %Document.Webpage{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title,
      content: chunk.content,
      tags: [],
      meta: meta
    }

    Client.index_document(:webpage, doc)
  end

  def insert_document(%GithubIssue.Chunk{} = chunk) do
    meta = %Document.Webpage.Meta{
      url: chunk.url
    }

    doc = %Document.GithubIssue{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title,
      content: chunk.content,
      tags: [],
      meta: meta
    }

    Client.index_document(:github_issue, doc)
  end

  def insert_document(%GithubDiscussion.Chunk{} = chunk) do
    meta = %Document.Webpage.Meta{
      url: chunk.url
    }

    doc = %Document.GithubDiscussion{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title,
      content: chunk.content,
      tags: [],
      meta: meta
    }

    Client.index_document(:github_discussion, doc)
  end

  def delete_document(source_type, id)
      when source_type in [
             :webpage,
             :github_issue,
             :github_discussion
           ] do
    Client.delete_document(source_type, id)
  end

  def search(sources, query, opts \\ []) do
    tags = opts[:tags]
    embedding = opts[:embedding]
    embedding_alpha = opts[:embedding_alpha] || 0.3

    args =
      sources
      |> Enum.map(fn %Canary.Sources.Source{id: source_id, config: %Ash.Union{type: type}} ->
        filter_by =
          [
            "source_id:=[#{source_id}]",
            if(tags != nil and tags != []) do
              "tags:=[#{Enum.join(tags, ",")}]"
            end
          ]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" && ")

        query_by = ["title", "content"] |> Enum.join(",")
        query_by_weights = [3, 2] |> Enum.join(",")

        arg = %{
          collection: to_string(type),
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
          stopwords: Canary.Index.Stopword.id()
        }

        if embedding do
          arg
          |> Map.put(
            :vector_query,
            "embedding:([#{Enum.join(embedding, ",")}], alpha: #{embedding_alpha})"
          )
        else
          arg
        end
      end)

    case Canary.Index.Client.multi_search(args) do
      {:ok, %Req.Response{status: 200, body: %{"results" => results}}} ->
        ret =
          results
          |> Enum.reject(fn %{"hits" => hits} -> length(hits) == 0 end)
          |> Enum.map(fn %{"hits" => hits} ->
            hits =
              hits
              |> Enum.map(fn hit ->
                %{
                  id: hit["document"]["id"],
                  source_id: hit["document"]["source_id"],
                  title: hit["highlight"]["title"]["snippet"] || hit["document"]["title"],
                  titles: hit["document"]["meta"]["titles"],
                  url: hit["document"]["meta"]["url"],
                  excerpt: hit["highlight"]["content"]["snippet"] || hit["document"]["content"],
                  tags: hit["document"]["tags"],
                  content: hit["document"]["content"],
                  tokens: hit["document"]["meta"]["tokens"]
                }
              end)

            %{
              source_id: hits |> Enum.at(0) |> Map.get(:source_id),
              hits: hits
            }
          end)

        {:ok, ret}

      {:ok, res} ->
        {:error, res}

      {:error, error} ->
        {:error, error}
    end
  end
end

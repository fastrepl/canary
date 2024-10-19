defmodule Canary.Sources.Document.Create do
  use Ash.Resource.Change

  alias Canary.Index.Trieve
  alias Canary.Sources.Chunk
  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue
  alias Canary.Sources.GithubDiscussion

  def init(opts) do
    if [
         :data_argument,
         :meta_attribute,
         :chunks_attribute,
         :tracking_id_attribute,
         :source_id_attribute
       ]
       |> Enum.any?(fn key -> is_nil(opts[key]) end) do
      {:error, :invalid_opts}
    else
      {:ok, opts}
    end
  end

  @impl true
  def batch_change(changesets, opts, _context) do
    changesets
    |> Enum.map(fn changeset ->
      data = Ash.Changeset.get_argument(changeset, opts[:data_argument])

      %{
        local_chunks: local_chunks,
        remote_chunks: remote_chunks,
        local_doc_meta: local_doc_meta,
        remote_group_meta: remote_group_meta,
        remote_tags: remote_tags
      } = transform_fetcher_result(data)

      changeset
      |> Ash.Changeset.force_change_attribute(opts[:tracking_id_attribute], Ash.UUID.generate())
      |> Ash.Changeset.change_attribute(opts[:meta_attribute], local_doc_meta)
      |> Ash.Changeset.change_attribute(opts[:chunks_attribute], local_chunks)
      |> Ash.Changeset.put_context(:remote_group_meta, remote_group_meta)
      |> Ash.Changeset.put_context(:remote_chunks, remote_chunks)
      |> Ash.Changeset.put_context(:remote_tags, remote_tags)
    end)
  end

  defp transform_fetcher_result(%Webpage.FetcherResult{} = data) do
    local_chunks =
      data.items
      |> Enum.map(fn _ -> %Chunk{index_id: Ash.UUID.generate()} end)

    remote_chunks =
      data.items
      |> Enum.map(fn item ->
        %{
          content: item.content,
          url: URI.parse(data.url) |> Map.put(:fragment, item.id) |> to_string(),
          meta: %{
            title: item.title
          }
        }
      end)

    local_doc_meta = %Ash.Union{
      type: :webpage,
      value: %{
        url: data.url,
        hash: :crypto.hash(:sha256, data.html) |> Base.encode16(case: :lower)
      }
    }

    remote_group_meta = %{
      type: :webpage,
      title: Enum.at(data.items, 0).title,
      url: data.url
    }

    %{
      local_chunks: local_chunks,
      remote_chunks: remote_chunks,
      local_doc_meta: local_doc_meta,
      remote_group_meta: remote_group_meta,
      remote_tags: data.tags
    }
  end

  defp transform_fetcher_result(%GithubIssue.FetcherResult{} = data) do
    local_chunks =
      data.items
      |> Enum.map(fn _ -> %Chunk{index_id: Ash.UUID.generate()} end)

    remote_chunks =
      data.items
      |> Enum.map(fn item ->
        %{
          content: item.content,
          url: data.root.url,
          title: data.root.title,
          created_at: item.created_at,
          meta: %{}
        }
      end)

    local_doc_meta = %Ash.Union{
      type: :github_issue,
      value: %{
        node_id: data.root.node_id
      }
    }

    remote_group_meta = %{
      type: :github_issue,
      title: data.root.title,
      url: data.root.url,
      closed: data.root.closed
    }

    %{
      local_chunks: local_chunks,
      remote_chunks: remote_chunks,
      local_doc_meta: local_doc_meta,
      remote_group_meta: remote_group_meta,
      remote_tags: []
    }
  end

  defp transform_fetcher_result(%GithubDiscussion.FetcherResult{} = data) do
    local_chunks =
      data.items
      |> Enum.map(fn _ -> %Chunk{index_id: Ash.UUID.generate()} end)

    remote_chunks =
      data.items
      |> Enum.map(fn item ->
        %{
          url: item.url,
          content: item.content,
          title: data.root.title,
          created_at: item.created_at,
          meta: %{}
        }
      end)

    local_doc_meta = %Ash.Union{
      type: :github_discussion,
      value: %{
        node_id: data.root.node_id
      }
    }

    remote_group_meta = %{
      type: :github_discussion,
      title: data.root.title,
      url: data.root.url,
      closed: data.root.closed,
      answered: data.root.answered
    }

    %{
      local_chunks: local_chunks,
      remote_chunks: remote_chunks,
      local_doc_meta: local_doc_meta,
      remote_group_meta: remote_group_meta,
      remote_tags: []
    }
  end

  @impl true
  def after_batch(changesets_and_results, opts, _context) do
    with :ok = create_groups(changesets_and_results, opts),
         :ok = create_chunks(changesets_and_results, opts) do
      changesets_and_results
      |> Enum.map(fn {_changeset, record} -> {:ok, record} end)
    end
  end

  defp create_groups(changesets_and_results, opts) do
    changesets_and_results
    |> Enum.map(fn {changeset, doc_record} ->
      %{
        tracking_id: Map.get(doc_record, opts[:tracking_id_attribute]),
        meta: changeset.context.remote_group_meta
      }
    end)
    |> Trieve.Client.upsert_groups()
  end

  defp create_chunks(changesets_and_results, opts) do
    changesets_and_results
    |> Enum.flat_map(fn {changeset, doc_record} ->
      group_tracking_id = Map.get(doc_record, opts[:tracking_id_attribute])

      local_chunks = Map.get(doc_record, opts[:chunks_attribute])
      remote_chunks = changeset.context.remote_chunks

      remote_chunks
      |> Enum.with_index()
      |> Enum.map(fn {chunk, index} ->
        %{
          tracking_id: Enum.at(local_chunks, index).index_id,
          group_tracking_id: group_tracking_id,
          content: chunk.content,
          url: chunk.url,
          meta: chunk.meta,
          source_id: Map.get(doc_record, opts[:source_id_attribute]),
          tags: changeset.context.remote_tags
        }
      end)
    end)
    |> Trieve.Client.upsert_chunks()
  end
end

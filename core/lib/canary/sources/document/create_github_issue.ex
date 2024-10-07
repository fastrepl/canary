defmodule Canary.Sources.Document.CreateGithubIssue do
  use Ash.Resource.Change

  alias Canary.Sources.GithubIssue

  @impl true
  def init(opts) do
    if [
         :source_id_argument,
         :fetcher_results_argument,
         :chunks_attribute,
         :meta_attribute
       ]
       |> Enum.any?(&is_nil(opts[&1])) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def before_batch(changesets, opts, _context) do
    changesets =
      changesets
      |> Enum.map(fn changeset ->
        changeset
        |> Ash.Changeset.force_change_attribute(:id, Ash.UUID.generate())
      end)

    chunk_inputs =
      changesets
      |> Enum.flat_map(fn changeset ->
        document_id = Ash.Changeset.get_attribute(changeset, :id)
        source_id = Ash.Changeset.get_argument(changeset, opts[:source_id_argument])
        fetcher_results = Ash.Changeset.get_argument(changeset, opts[:fetcher_results_argument])

        fetcher_results
        |> Enum.with_index(0)
        |> Enum.map(fn {%GithubIssue.FetcherResult{} = item, index} ->
          %{
            source_id: source_id,
            document_id: document_id,
            node_id: item.node_id,
            is_parent: index == 0,
            title: item.title,
            content: item.content,
            url: item.url,
            created_at: item.created_at,
            author_name: item.author_name,
            author_avatar_url: item.author_avatar_url,
            comment: item.comment
          }
        end)
      end)

    bulk_opts = [return_errors?: true, return_records?: true, batch_size: 100]

    case Ash.bulk_create(chunk_inputs, GithubIssue.Chunk, :create, bulk_opts) do
      %Ash.BulkResult{status: :success, records: records} ->
        doc_id_to_chunks =
          records
          |> Enum.group_by(& &1.document_id)

        changesets
        |> Enum.map(fn changeset ->
          document_id = Ash.Changeset.get_attribute(changeset, :id)
          chunks = doc_id_to_chunks[document_id] || []

          changeset
          |> Ash.Changeset.change_attribute(opts[:chunks_attribute], wrap_union(chunks))
        end)

      %Ash.BulkResult{errors: errors} ->
        changesets
        |> Enum.map(fn changeset ->
          changeset
          |> Ash.Changeset.add_error(errors)
          |> Ash.Changeset.change_attribute(opts[:chunks_attribute], [])
        end)
    end
  end

  @impl true
  def batch_change(changesets, opts, _context) do
    changesets
    |> Enum.map(fn changeset ->
      fetcher_results = Ash.Changeset.get_argument(changeset, opts[:fetcher_results_argument])

      top_level_item = fetcher_results |> Enum.at(0)

      meta =
        GithubIssue.DocumentMeta
        |> Ash.Changeset.for_create(:create, %{
          title: top_level_item.title,
          url: top_level_item.url,
          closed: top_level_item.closed
        })
        |> Ash.create!()
        |> then(&wrap_union/1)

      changeset
      |> Ash.Changeset.change_attribute(opts[:meta_attribute], meta)
    end)
  end

  defp wrap_union(v) when is_list(v), do: Enum.map(v, &wrap_union/1)
  defp wrap_union(%Ash.Union{} = v), do: v
  defp wrap_union(v), do: %Ash.Union{type: :github_issue, value: v}
end

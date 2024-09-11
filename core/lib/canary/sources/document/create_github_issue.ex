defmodule Canary.Sources.Document.CreateGithubIssue do
  use Ash.Resource.Change

  alias Canary.Sources.Document
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
  def change(changeset, opts, _context) do
    source_id = Ash.Changeset.get_argument(changeset, opts[:source_id_argument])
    fetcher_results = Ash.Changeset.get_argument(changeset, opts[:fetcher_results_argument])

    changeset
    |> Ash.Changeset.change_attribute(
      opts[:meta_attribute],
      wrap_union(%GithubIssue.DocumentMeta{})
    )
    |> Ash.Changeset.change_attribute(opts[:chunks_attribute], [])
    |> Ash.Changeset.after_action(fn _, record ->
      result =
        fetcher_results
        |> Enum.map(fn %GithubIssue.FetcherResult{} = item ->
          %{
            source_id: source_id,
            node_id: item.node_id,
            title: item.title,
            content: item.content,
            url: item.url,
            created_at: item.created_at,
            author_name: item.author_name,
            author_avatar_url: item.author_avatar_url,
            comment: item.comment
          }
        end)
        |> Ash.bulk_create(GithubIssue.Chunk, :create,
          return_errors?: true,
          return_records?: true
        )

      case result do
        %Ash.BulkResult{status: :success, records: records} ->
          case Document.update(
                 record,
                 wrap_union(%GithubIssue.DocumentMeta{}),
                 Enum.map(records, &wrap_union/1)
               ) do
            {:ok, updated_record} -> {:ok, updated_record}
            error -> error
          end

        %Ash.BulkResult{errors: errors} ->
          {:error, errors}
      end
    end)
  end

  defp wrap_union(%Ash.Union{} = v), do: v
  defp wrap_union(v), do: %Ash.Union{type: :github_issue, value: v}
end

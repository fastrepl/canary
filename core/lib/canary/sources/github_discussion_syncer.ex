defmodule Canary.Sources.GithubDiscussion.Syncer do
  alias Canary.Sources.Document

  require Ash.Query

  def run(source_id, list_of_results) do
    destroy_result =
      Document
      |> Ash.Query.filter(source_id == ^source_id)
      |> Ash.bulk_destroy(:destroy, %{}, return_errors?: true)

    create_result =
      list_of_results
      |> Enum.map(&%{source_id: source_id, fetcher_results: &1})
      |> Ash.bulk_create(Document, :create_github_discussion, return_errors?: true)

    with %Ash.BulkResult{status: :success} <- destroy_result,
         %Ash.BulkResult{status: :success} <- create_result do
      :ok
    else
      %Ash.BulkResult{errors: errors} ->
        {:error, errors}
    end
  end
end

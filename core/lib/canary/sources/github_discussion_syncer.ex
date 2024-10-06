defmodule Canary.Sources.GithubDiscussion.Syncer do
  alias Canary.Sources.Document
  alias Canary.Sources.GithubDiscussion.FetcherResult

  require Ash.Query

  @spec run(binary(), list(FetcherResult.t())) :: :ok | {:error, any()}
  def run(source_id, list_of_results) do
    with %Ash.BulkResult{status: :success} <- destroy(source_id),
         %Ash.BulkResult{status: :success} <- create(source_id, list_of_results) do
      :ok
    else
      %Ash.BulkResult{errors: errors} ->
        {:error, errors}
    end
  end

  defp destroy(source_id) do
    Document
    |> Ash.Query.filter(source_id == ^source_id)
    |> Ash.bulk_destroy(:destroy, %{}, return_errors?: true, batch_size: 50)
  end

  defp create(source_id, incomings) do
    incomings
    |> Enum.map(&%{source_id: source_id, fetcher_results: &1})
    |> Ash.bulk_create(Document, :create_github_discussion, return_errors?: true, batch_size: 50)
  end
end

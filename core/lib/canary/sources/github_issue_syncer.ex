defmodule Canary.Sources.GithubIssue.Syncer do
  # alias Canary.Sources.GithubIssue.DocumentMeta
  # alias Canary.Sources.GithubIssue.FetcherResult

  alias Canary.Sources.Document

  def run(source_id, incomings) do
    Document
    |> Ash.Changeset.for_create(:create_github_issue, %{
      source_id: source_id,
      fetcher_results: incomings
    })
    |> Ash.create()

    :ok
  end
end

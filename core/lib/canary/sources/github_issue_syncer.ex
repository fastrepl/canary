defmodule Canary.Sources.GithubIssue.Syncer do
  # alias Canary.Sources.GithubIssue.DocumentMeta
  # alias Canary.Sources.GithubIssue.FetcherResult

  # alias Canary.Sources.Document

  @spec run(binary(), list(FetcherResult.t())) :: :ok | {:error, any()}
  def run(source_id, incomings) do
    IO.inspect(incomings)
    IO.inspect(source_id)

    :ok
  end
end

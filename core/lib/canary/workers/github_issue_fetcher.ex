defmodule Canary.Workers.GithubIssueFetcher do
  use Oban.Worker, queue: :github_fetcher, max_attempts: 2

  alias Canary.Sources.Source
  alias Canary.Sources.GithubIssue.Config

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{config: %Ash.Union{type: :github_issue, value: %Config{} = _config}}) do
    :ok
  end
end

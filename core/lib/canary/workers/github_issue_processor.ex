defmodule Canary.Workers.GithubIssueProcessor do
  use Oban.Worker,
    queue: :github_processor,
    max_attempts: 1,
    unique: [
      period: if(Application.get_env(:canary, :env) == :prod, do: 24 * 60 * 60, else: 10),
      fields: [:worker, :queue, :args],
      states: Oban.Job.states() -- [:discarded, :cancelled],
      timestamp: :scheduled_at
    ]

  alias Canary.Sources.Source
  alias Canary.Sources.GithubIssue

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{id: source_id} = source) do
    with {:ok, incomings} <- GithubIssue.Fetcher.run(source),
         :ok <- GithubIssue.Syncer.run(source_id, incomings) do
      Source.update_overview(source)
    end
  end
end

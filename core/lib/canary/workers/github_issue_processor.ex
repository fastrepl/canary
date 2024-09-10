defmodule Canary.Workers.GithubIssueProcessor do
  use Oban.Worker, queue: :github_processor, max_attempts: 2

  alias Canary.Sources.Event
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
    Event.create(source_id, %Event.Meta{
      level: :info,
      message: "github issue fetcher started"
    })

    {:ok, incomings} = GithubIssue.Fetcher.run(source)
    :ok = GithubIssue.Syncer.run(source_id, incomings)

    Event.create(source_id, %Event.Meta{
      level: :info,
      message: "github issue fetcher ended"
    })

    :ok
  end
end

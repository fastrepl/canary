defmodule Canary.Workers.SourceProcessor do
  use Oban.Worker,
    queue: :default,
    max_attempts: 1

  require Ash.Query

  alias Canary.Workers
  alias Canary.Sources.Source

  @impl true
  def perform(%Oban.Job{}) do
    sources =
      Source
      |> Ash.Query.select([:id, :config, :last_fetched_at])
      |> Ash.read!()

    sources
    |> Enum.filter(fn
      %Source{last_fetched_at: nil} -> false
      %Source{last_fetched_at: time} -> DateTime.diff(DateTime.utc_now(), time, :hour) > 18
    end)
    |> Enum.map(fn %Source{id: id, config: %Ash.Union{type: type}} ->
      case type do
        :webpage -> Workers.WebpageProcessor.new(%{source_id: id})
        :github_issue -> Workers.GithubIssueProcessor.new(%{source_id: id})
        :github_discussion -> Workers.GithubDiscussionProcessor.new(%{source_id: id})
      end
    end)
    |> Oban.insert_all()

    :ok
  end
end

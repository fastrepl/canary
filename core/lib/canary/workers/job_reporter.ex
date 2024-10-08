defmodule Canary.Workers.JobReporter do
  alias Canary.Workers
  alias Canary.Sources.Source
  alias Canary.Sources.Event

  require Logger

  @processors Enum.map(
                [
                  Workers.WebpageProcessor,
                  Workers.GithubIssueProcessor,
                  Workers.GithubDiscussionProcessor
                ],
                &(&1 |> to_string() |> String.trim_leading("Elixir."))
              )

  def handle_job(
        [:oban, :job, event],
        _measure,
        %{job: %Oban.Job{args: args, worker: worker}},
        _opts
      )
      when event in [:start, :stop, :exception] and worker in @processors do
    source = Ash.get!(Source, args["source_id"])

    try do
      case event do
        :start ->
          Source.update_state(source, :running)

          Event.create(source.id, %Event.Meta{
            level: :info,
            message: "fetcher started"
          })

        :stop ->
          Source.update_state(source, :idle)
          Source.update_last_fetched_at(source)

          Event.create(source.id, %Event.Meta{
            level: :info,
            message: "fetcher ended"
          })

        :exception ->
          Source.update_state(source, :error)
          Source.update_last_fetched_at(source)

          Event.create(source.id, %Event.Meta{
            level: :info,
            message: "fetcher failed"
          })
      end
    rescue
      e ->
        Logger.info(Exception.format(:error, e, __STACKTRACE__))
    end
  end

  def handle_job(_event, _measure, _meta, _opts), do: :ok
end

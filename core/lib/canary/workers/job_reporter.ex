defmodule Canary.Workers.JobReporter do
  alias Canary.Workers
  alias Canary.Sources.Source
  alias Canary.Sources.Event

  @processors Enum.map(
                [
                  Workers.WebpageProcessor,
                  Workers.OpenAPIProcessor,
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
  end

  def handle_job(
        [:oban, :job, event],
        _measure,
        %{job: %Oban.Job{worker: worker}, attempt: attempt} = meta,
        _opts
      )
      when event in [:exception] do
    if worker in @processors do
      if attempt > 1 do
        notify(meta)
      end
    else
      notify(meta)
    end

    :ok
  end

  def handle_job(_event, _measure, _meta, _opts), do: :ok

  # https://hexdocs.pm/oban/Oban.Telemetry.html#module-examples
  defp notify(meta) do
    context = Map.take(meta, [:id, :args, :queue, :worker])
    Honeybadger.notify(meta.reason, metadata: context, stacktrace: meta.stacktrace)
  end
end

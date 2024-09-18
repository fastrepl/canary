defmodule Canary.Workers.Reporter do
  alias Canary.Workers
  alias Canary.Sources.Source
  alias Canary.Sources.Event

  def handle_job([:oban, :job, event], _measure, meta, _opts) do
    %Oban.Job{args: args, worker: worker} = meta.job

    if worker in Enum.map(
         [
           Workers.WebpageProcessor,
           Workers.GithubIssueProcessor,
           Workers.GithubDiscussionProcessor
         ],
         &worker_name/1
       ) do
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
    else
      :ok
    end
  end

  defp worker_name(module) do
    module |> to_string() |> String.trim_leading("Elixir.")
  end
end

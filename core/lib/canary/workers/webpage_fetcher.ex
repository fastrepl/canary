defmodule Canary.Workers.WebpageFetcher do
  use Oban.Worker, queue: :web_fetcher, max_attempts: 2

  alias Canary.Sources.Event
  alias Canary.Sources.Source
  alias Canary.Sources.Webpage

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{
         id: source_id,
         config: %Ash.Union{type: :webpage, value: %Webpage.Config{} = config}
       }) do
    Event.create(source_id, %Event.Meta{
      level: :info,
      message: "crawler started"
    })

    {:ok, incomings} = Webpage.Fetcher.run(config)
    :ok = Webpage.Syncer.run(source_id, incomings)

    Event.create(source_id, %Event.Meta{
      level: :info,
      message: "crawler ended"
    })

    :ok
  end
end

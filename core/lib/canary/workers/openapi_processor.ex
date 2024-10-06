defmodule Canary.Workers.OpenAPIProcessor do
  use Oban.Worker,
    queue: :openapi_processor,
    max_attempts: 2,
    unique: [
      period: if(Application.get_env(:canary, :env) == :prod, do: 24 * 60 * 60, else: 10),
      fields: [:worker, :queue, :args],
      states: Oban.Job.states() -- [:discarded, :cancelled],
      timestamp: :scheduled_at
    ]

  alias Canary.Sources.Source
  alias Canary.Sources.OpenAPI

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{id: source_id, config: %Ash.Union{type: :openapi, value: config}}) do
    with {:ok, %OpenAPI.FetcherResult{} = incomings} = OpenAPI.Fetcher.run(config) do
      OpenAPI.Syncer.run(source_id, incomings)
    end
  end
end

defmodule Canary.Workers.WebpageProcessor do
  use Oban.Worker,
    queue: :webpage_processor,
    max_attempts: 1,
    unique: [
      period:
        cond do
          Application.get_env(:canary, :self_host) -> 10
          Application.get_env(:canary, :env) != :prod -> 10
          true -> 24 * 60 * 60
        end,
      fields: [:worker, :queue, :args],
      states: Oban.Job.states() -- [:discarded, :cancelled],
      timestamp: :scheduled_at
    ]

  alias Canary.Sources.Source
  alias Canary.Sources.Webpage

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{id: source_id, config: %Ash.Union{type: :webpage, value: config}} = source) do
    with {:ok, incomings} = Webpage.Fetcher.run(config),
         :ok <- Webpage.Syncer.run(source_id, Enum.to_list(incomings)) do
      Source.update_overview(source)
    end
  end
end

defmodule Canary.Workers.SourceUpdate do
  use Oban.Worker, queue: :updater, max_attempts: 2
  require Ash.Query

  @impl true
  def perform(%Oban.Job{}) do
    sources =
      Canary.Sources.Source
      |> Ash.Query.filter(type == :web)
      |> Ash.read!()

    sources
    |> Enum.map(&%{source_id: &1.id})
    |> Enum.map(&Canary.Workers.Fetcher.new/1)
    |> Oban.insert_all()

    :ok
  end
end

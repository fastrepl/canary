defmodule Canary.Workers.Updater do
  use Oban.Worker, max_attempts: 1

  require Ash.Query

  @impl true
  def perform(_) do
    inputs =
      Canary.Sources.Source
      |> Ash.Query.filter(type: :web)
      |> Ash.read!()
      |> Enum.map(&%{source_id: &1.id})

    inputs
    |> Enum.map(&Canary.Workers.Fetcher.new/1)
    |> Enum.each(&Oban.insert/1)

    :ok
  end
end

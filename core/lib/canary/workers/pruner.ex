defmodule Canary.Workers.Pruner do
  use Oban.Worker, queue: :pruner, max_attempts: 2

  require Ash.Query

  alias Canary.Sources.Source
  alias Canary.Sources.Document

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{} = src) do
    src = src |> Ash.load!(:updated_at)

    Document
    |> Ash.Query.filter(
      source_id == ^src.id and updated_at < ^DateTime.add(src.updated_at, -1, :hour)
    )
    |> Ash.bulk_destroy!(:destroy, %{})

    :ok
  end
end

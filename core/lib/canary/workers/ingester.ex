defmodule Canary.Workers.Ingester do
  use Oban.Worker, queue: :ingester, max_attempts: 3

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id, "path" => path, "content" => content}}) do
    case Ash.get(Canary.Sources.Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source, path, content)
    end
  end

  defp process(source, path, content) do
    Canary.Sources.Document.ingest_text(source, path, content)
  end
end

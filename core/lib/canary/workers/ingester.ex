defmodule Canary.Workers.Ingester do
  use Oban.Worker, queue: :ingester, max_attempts: 3

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id, "url" => url, "content" => md}}) do
    case Ash.get(Canary.Sources.Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source, md, url)
    end
  end

  defp process(source, md, url) do
    Canary.Sources.Document.ingest_text(source, md, url)
  end
end

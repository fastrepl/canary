defmodule Canary.Workers.Ingester do
  use Oban.Worker, queue: :ingester, max_attempts: 3

  @impl true
  def perform(%Oban.Job{args: args}) do
    %{"source_id" => id, "url" => url, "title" => title, "content" => content} = args

    case Ash.get(Canary.Sources.Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source, url, title, content)
    end
  end

  defp process(source, url, title, content) do
    Canary.Sources.Document.ingest_text(source, url, title, content)
  end
end

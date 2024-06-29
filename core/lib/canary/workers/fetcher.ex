defmodule Canary.Workers.Fetcher do
  use Oban.Worker, queue: :fetcher, max_attempts: 5

  alias Canary.Sources.Source
  alias Canary.Sources.Document

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{type: :web} = src) do
    {:ok, pairs} = Canary.Crawler.run(src.web_base_url)

    inputs =
      pairs
      |> Enum.flat_map(fn {url, html} ->
        html
        |> Canary.Reader.html_to_md()
        |> Canary.Reader.chunk_markdown()
        |> Enum.map(&%{source_id: src.id, source_url: url, content: &1})
      end)

    with %Ash.BulkResult{status: :success} <-
           inputs
           |> Ash.bulk_create(Document, :ingest,
             return_records?: false,
             return_errors?: true
           ),
         _ <-
           Canary.Workers.Pruner.new(%{"source_id" => src.id})
           |> Oban.insert!(schedule_in: 1 * 30) do
      :ok
    else
      error -> {:error, error}
    end
  end
end

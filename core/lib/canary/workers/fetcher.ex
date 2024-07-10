defmodule Canary.Workers.Fetcher do
  use Oban.Worker, queue: :fetcher, max_attempts: 2

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
        title = html |> Canary.Reader.title_from_html()

        contents =
          html
          |> Canary.Reader.markdown_from_html()
          |> Canary.Reader.chunk_markdown()

        contents
        |> Enum.map(&%{source: src, url: url, title: title, content: &1})
      end)

    opts = [return_records?: false, return_errors?: true]

    case Ash.bulk_create(inputs, Document, :ingest_text, opts) do
      %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
      _ -> {:ok, src}
    end
  end
end

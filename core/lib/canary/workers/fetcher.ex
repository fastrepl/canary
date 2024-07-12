defmodule Canary.Workers.Fetcher do
  use Oban.Worker, queue: :fetcher, max_attempts: 2

  alias Canary.Sources.Source
  alias Canary.Sources.Document

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id, load: [:documents]) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{type: :web, documents: documents} = src) do
    {:ok, pairs} = Canary.Crawler.run(src.web_base_url)

    inputs =
      pairs
      |> Enum.map(fn {url, html} ->
        title = html |> Canary.Reader.title_from_html()
        content = html |> Canary.Reader.markdown_from_html()
        %{source: src, url: url, title: title, content: content}
      end)

    to_delete =
      documents
      |> Enum.filter(fn doc ->
        found = Enum.find(inputs, &(&1.url == doc.url))
        is_nil(found) or doc.content_hash != :crypto.hash(:sha256, found.content)
      end)

    case Ash.bulk_destroy(to_delete, :destroy, %{}) do
      %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
      _ -> {:ok, src}
    end

    to_create =
      inputs
      |> Enum.reject(fn input -> Enum.any?(documents, &(&1.url == input.url)) end)

    opts = [return_records?: false, return_errors?: true]

    case Ash.bulk_create(to_create, Document, :ingest_text, opts) do
      %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
      _ -> {:ok, src}
    end
  end
end

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
        title = Canary.Reader.title_from_html(html)
        content = Canary.Reader.markdown_from_html(html)
        %{source: src.id, url: url, title: title, content: content}
      end)

    opts = [return_records?: false, return_errors?: true]

    case Ash.bulk_destroy(documents, :destroy, %{}, opts) do
      %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
      _ -> {:ok, src}
    end

    case Ash.bulk_create(inputs, Document, :create, opts) do
      %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
      _ -> {:ok, src}
    end
  end
end

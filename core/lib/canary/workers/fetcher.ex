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
    {:ok, pairs} = Canary.Crawler.run(src.web_url_base)

    inputs =
      pairs
      |> Enum.map(fn {url, html} ->
        title = Canary.Reader.title_from_html(html)
        %{source_id: src.id, url: url, title: title, html: html}
      end)

    bulk_opts = [return_records?: false, return_errors?: true]

    removed_documents =
      documents
      |> Enum.reject(fn doc -> Enum.any?(inputs, &same?(doc, &1)) end)
      |> Enum.map(&Map.put(&1, :source_id, src.id))

    updated_documents =
      documents
      |> Enum.filter(fn doc -> Enum.any?(inputs, &updated?(doc, &1)) end)
      |> Enum.map(&Map.put(&1, :source_id, src.id))

    added_documents =
      inputs
      |> Enum.reject(fn doc -> Enum.any?(documents, &same?(doc, &1)) end)

    with :ok =
           (updated_documents ++ removed_documents)
           |> Ash.bulk_destroy(:destroy, %{}, bulk_opts)
           |> wrap_ash_bulk(),
         :ok =
           (updated_documents ++ added_documents)
           |> Ash.bulk_create(Document, :create, bulk_opts)
           |> wrap_ash_bulk() do
      :ok
    end
  end

  defp wrap_ash_bulk(%Ash.BulkResult{} = result) do
    case result do
      %Ash.BulkResult{status: :success} -> :ok
      %Ash.BulkResult{status: :error, errors: errors} -> {:error, errors}
      other -> {:error, other}
    end
  end

  defp updated?(doc_a, doc_b) do
    doc_a.url == doc_b.url && doc_a.content != doc_b.content
  end

  defp same?(doc_a, doc_b) do
    doc_a.url == doc_b.url && doc_a.content == doc_b.content
  end
end

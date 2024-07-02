defmodule Canary.Workers.Fetcher do
  require Ash.Query
  use Oban.Worker, queue: :fetcher, max_attempts: 3

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Canary.Sources.Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Canary.Sources.Source{type: :web} = src) do
    # {:ok, pairs} = Canary.Crawler.run(src.web_base_url)

    # existing_docs =
    #   src
    #   |> Ash.load!(:documents)
    #   |> Map.get(:documents, [])
    #   |> Enum.reduce(%{}, fn doc, acc ->
    #     acc |> Map.put({doc.url, doc.content_hash}, doc)
    #   end)

    # docs_to_delete = existing_docs
    # |> Enum.filter(fn {url, hash} -> hash not in Map.keys(new_docs) end)

    # to_delete
    # |> Enum.map(fn pair -> Map.get(existing_docs, pair) end)
    # |> then(&Ash.bulk_destroy!(Canary.Sources.Document, :destroy, &1, return_records?: false))

    # to_create
    # |> Enum.map(fn {url, _hash} = pair ->
    #   md =
    #     new_docs
    #     |> Map.get(pair)
    #     |> Canary.Reader.html_to_md()

    #   Canary.Workers.Ingester.new(%{"source_id" => src.id, "url" => url, "content" => md})
    # end)
    # |> Oban.insert_all(timeout: 15_000)

    :ok
  end
end

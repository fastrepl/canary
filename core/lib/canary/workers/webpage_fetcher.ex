defmodule Canary.Workers.WebpageFetcher do
  use Oban.Worker, queue: :web_fetcher, max_attempts: 2

  require Ash.Query

  alias Canary.Sources.Source
  alias Canary.Sources.Webpage
  alias Canary.Sources.Document

  @impl true
  def perform(%Oban.Job{args: %{"source_id" => id}}) do
    case Ash.get(Source, id) do
      {:error, _} -> :ok
      {:ok, source} -> process(source)
    end
  end

  defp process(%Source{
         id: source_id,
         config: %Ash.Union{type: :webpage, value: %Webpage.Config{} = config}
       }) do
    {:ok, incomings} =
      Canary.Crawler.run(Enum.at(config.start_urls, 0),
        include_patterns: config.url_include_patterns,
        exclude_patterns: config.url_exclude_patterns
      )

    existing_docs =
      Ash.Query.for_read(Document, :find, %{
        source_id: source_id,
        type: :webpage,
        key: :url,
        values: Enum.map(incomings, &elem(&1, 0))
      })
      |> Ash.Query.build(select: [:id, :meta])
      |> Ash.read!()

    incoming_map = Map.new(incomings)
    existing_map = Map.new(existing_docs, &{&1.meta.url, &1})

    {to_create, to_update, to_keep} =
      Enum.reduce(incoming_map, {[], [], []}, fn {url, html}, {create, update, keep} ->
        case Map.get(existing_map, url) do
          nil ->
            {[{url, html} | create], update, keep}

          doc ->
            hash =
              html
              |> then(&:crypto.hash(:sha256, &1))
              |> Base.encode16(case: :lower)

            if hash == doc.meta.hash do
              {create, update, [doc.id | keep]}
            else
              {create, [{url, html} | update], keep}
            end
        end
      end)

    IO.puts("#{Enum.count(to_create)} new documents, #{Enum.count(to_update)} updated documents")

    total_ids =
      Ash.Query.for_read(Document, :read, %{})
      |> Ash.Query.filter(source_id == ^source_id)
      |> Ash.Query.build(select: [:id])
      |> Ash.read!()
      |> Enum.map(& &1.id)

    destroy_result =
      Document
      |> Ash.Query.filter(id in ^(total_ids -- to_keep))
      |> Ash.bulk_destroy(:destroy, %{}, return_errors?: true)

    IO.inspect(destroy_result, label: "destroy_result")

    # TODO: This will just fail if scraper fails
    create_result =
      (to_create ++ to_update)
      |> Enum.map(fn {url, html} -> %{source_id: source_id, url: url, html: html} end)
      |> Ash.bulk_create(Document, :create_webpage, return_errors?: true)

    IO.inspect(create_result, label: "create_result")

    # if destroy_result.status == :error or create_result.status == :error do
    #   {:error, {destroy_result.errors, create_result.errors}}
    # else
    #   :ok
    # end

    :ok
  end
end

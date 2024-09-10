defmodule Canary.Sources.Webpage.Syncer do
  alias Canary.Sources.Webpage.DocumentMeta
  alias Canary.Sources.Webpage.FetcherResult

  alias Canary.Sources.Document

  require Ash.Query

  @spec run(binary(), list(FetcherResult.t())) :: :ok | {:error, any()}
  def run(source_id, incomings) do
    existings =
      Ash.Query.for_read(Document, :find, %{source_id: source_id, type: :webpage})
      |> Ash.Query.build(select: [:id, :meta])
      |> Ash.read!()

    creates =
      incomings
      |> Enum.filter(fn incoming ->
        Enum.all?(existings, fn existing -> not url_eq?(existing, incoming) end)
      end)

    destroys =
      existings
      |> Enum.filter(fn existing ->
        Enum.all?(incomings, fn incoming -> not url_eq?(existing, incoming) end)
      end)

    updates =
      incomings
      |> Enum.filter(fn incoming ->
        found = existings |> Enum.find(fn existing -> url_eq?(existing, incoming) end)
        found && not hash_eq?(found, incoming)
      end)

    destroy_result =
      Document
      |> Ash.Query.filter(id in ^(Enum.map(destroys, & &1.id) ++ Enum.map(updates, & &1.id)))
      |> Ash.bulk_destroy(:destroy, %{}, return_errors?: true)

    create_result =
      (creates ++ updates)
      |> Enum.map(fn %FetcherResult{url: url, html: html} ->
        %{source_id: source_id, url: url, html: html}
      end)
      |> Ash.bulk_create(Document, :create_webpage, return_errors?: true)

    with %Ash.BulkResult{status: :success} <- destroy_result,
         %Ash.BulkResult{status: :success} <- create_result do
      :ok
    end
  end

  defp url_eq?(
         %Document{meta: %Ash.Union{type: :webpage, value: %DocumentMeta{url: url_a}}},
         %FetcherResult{url: url_b}
       ) do
    url_a == url_b
  end

  defp hash_eq?(
         %Document{meta: %Ash.Union{type: :webpage, value: %DocumentMeta{hash: hash_a}}},
         %FetcherResult{html: html}
       ) do
    hash_b =
      html
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)

    hash_a == hash_b
  end
end

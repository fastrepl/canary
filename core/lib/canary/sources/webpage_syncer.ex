defmodule Canary.Sources.Webpage.Syncer do
  alias Canary.Sources.Document
  alias Canary.Sources.Webpage.DocumentMeta
  alias Canary.Sources.Webpage.FetcherResult

  require Ash.Query

  @spec run(binary(), list(FetcherResult.t())) :: :ok | {:error, any()}
  def run(source_id, inputs) do
    docs_existing =
      Document
      |> Ash.Query.filter(source_id == ^source_id)
      |> Ash.Query.build(select: [:id, :meta])
      |> Ash.read!()

    inputs_for_create =
      inputs
      |> Enum.filter(fn %FetcherResult{} = input ->
        Enum.all?(docs_existing, fn existing -> not url_eq?(existing, input) end)
      end)

    docs_for_destroy =
      docs_existing
      |> Enum.filter(fn %Document{} = existing ->
        Enum.all?(inputs, fn input -> not url_eq?(existing, input) end)
      end)

    inputs_for_update =
      inputs
      |> Enum.filter(fn %FetcherResult{} = input ->
        found = docs_existing |> Enum.find(fn existing -> url_eq?(existing, input) end)
        found && not hash_eq?(found, input)
      end)

    docs_for_update =
      docs_existing
      |> Enum.filter(fn %Document{} = existing ->
        Enum.any?(inputs_for_update, fn input -> url_eq?(existing, input) end)
      end)

    ids_for_destroy = Enum.map(docs_for_destroy, & &1.id) ++ Enum.map(docs_for_update, & &1.id)

    destroy_result =
      Document
      |> Ash.Query.filter(id in ^ids_for_destroy)
      |> Ash.bulk_destroy(:destroy, %{}, return_errors?: true)

    create_result =
      (inputs_for_create ++ inputs_for_update)
      |> Enum.map(fn %FetcherResult{} = fetcher_result ->
        %{source_id: source_id, fetcher_result: fetcher_result}
      end)
      |> Ash.bulk_create(Document, :create_webpage, return_errors?: true)

    with %Ash.BulkResult{status: :success} <- destroy_result,
         %Ash.BulkResult{status: :success} <- create_result do
      :ok
    else
      %Ash.BulkResult{errors: errors} ->
        {:error, errors}
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

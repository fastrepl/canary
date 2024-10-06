defmodule Canary.Sources.OpenAPI.Syncer do
  alias Canary.Sources.Document
  alias Canary.Sources.OpenAPI

  require Ash.Query

  def run(source_id, %OpenAPI.FetcherResult{} = incomings) do
    existing_doc =
      Document
      |> Ash.Query.filter(source_id == ^source_id)
      |> Ash.Query.build(select: [:id, :meta])
      |> Ash.read!()
      |> Enum.at(0, nil)

    if hash_eq?(existing_doc, incomings) do
      :ok
    else
      create_changeset =
        Ash.Changeset.for_create(Document, :create_openapi, %{
          source_id: source_id,
          fetcher_result: incomings
        })

      with {:ok, %{id: id}} <- Ash.create(create_changeset),
           :ok <- remove_docs(source_id, exclude_id: id) do
        :ok
      end
    end
  end

  defp remove_docs(source_id, opts) do
    exclude_id = opts[:exclude_id] || ""

    case Document
         |> Ash.Query.filter(source_id == ^source_id and id != ^exclude_id)
         |> Ash.bulk_destroy(:destroy, %{}, return_errors?: true) do
      %Ash.BulkResult{status: :success} -> :ok
      %Ash.BulkResult{errors: errors} -> {:error, errors}
    end
  end

  defp hash_eq?(nil, _), do: false

  defp hash_eq?(
         %Document{meta: %Ash.Union{type: :openapi, value: %OpenAPI.DocumentMeta{hash: hash_a}}},
         %OpenAPI.FetcherResult{schema: %OpenApiSpex.OpenApi{} = schema}
       ) do
    hash_b =
      schema
      |> Jason.encode!()
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)

    hash_a == hash_b
  end
end

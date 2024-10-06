defmodule Canary.Sources.Document.CreateOpenAPI do
  use Ash.Resource.Change

  alias Canary.Sources.Document
  alias Canary.Sources.OpenAPI

  @impl true
  def init(opts) do
    if [
         :source_id_argument,
         :fetcher_result_argument,
         :chunks_attribute,
         :meta_attribute
       ]
       |> Enum.any?(&is_nil(opts[&1])) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    source_id = Ash.Changeset.get_argument(changeset, opts[:source_id_argument])

    %OpenAPI.FetcherResult{schema: %OpenApiSpex.OpenApi{} = schema, served_url: served_url} =
      Ash.Changeset.get_argument(changeset, opts[:fetcher_result_argument])

    changeset
    |> Ash.Changeset.change_attribute(opts[:meta_attribute], wrap_union(%OpenAPI.DocumentMeta{}))
    |> Ash.Changeset.change_attribute(opts[:chunks_attribute], [])
    |> Ash.Changeset.after_action(fn _, record ->
      hash =
        schema
        |> Jason.encode!()
        |> then(&:crypto.hash(:sha256, &1))
        |> Base.encode16(case: :lower)

      chunks_create_result =
        schema.paths
        |> Enum.map(fn
          {path, %OpenApiSpex.PathItem{get: get, post: post, put: put, delete: delete}} ->
            %{
              source_id: source_id,
              document_id: record.id,
              url: render_url(served_url, path),
              path: path,
              get: render_operation(get),
              post: render_operation(post),
              put: render_operation(put),
              delete: render_operation(delete)
            }
        end)
        |> Ash.bulk_create(OpenAPI.Chunk, :create,
          return_errors?: true,
          return_records?: true
        )

      meta = %OpenAPI.DocumentMeta{hash: hash}

      case chunks_create_result do
        %Ash.BulkResult{status: :success, records: records} ->
          case Document.update(record, wrap_union(meta), Enum.map(records, &wrap_union/1)) do
            {:ok, updated_record} -> {:ok, updated_record}
            error -> error
          end

        %Ash.BulkResult{errors: errors} ->
          {:error, errors}
      end
    end)
  end

  defp render_url(base_url, path) do
    URI.parse(base_url)
    |> Map.put(:fragment, ":~:text=#{path}")
    |> URI.to_string()
  end

  defp render_operation(nil), do: nil

  defp render_operation(%OpenApiSpex.Operation{} = op) do
    [op.summary, op.description, op.operationId]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" / ")
  end

  defp wrap_union(%Ash.Union{} = v), do: v
  defp wrap_union(v), do: %Ash.Union{type: :openapi, value: v}
end

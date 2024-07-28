defmodule Canary.Sources.Changes.Index.Insert do
  use Ash.Resource.Change

  @error_msg "failed to insert document into index"

  @impl true
  def change(changeset, opts, _context) do
    doc = doc_from_changeset(changeset, opts)

    case Canary.Index.Document.insert(doc) do
      {:ok, result} ->
        changeset
        |> Ash.Changeset.force_change_attribute(opts[:result_attr], result["id"])

      {:error, _} ->
        changeset |> Ash.Changeset.add_error(field: opts[:result_attr], error: @error_msg)
    end
  end

  defp doc_from_changeset(changeset, opts) do
    opts[:source_attrs]
    |> Enum.reduce(%{}, fn key, acc ->
      value = Ash.Changeset.get_argument(changeset, key)
      acc |> Map.put(key, value)
    end)
  end
end

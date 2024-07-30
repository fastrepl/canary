defmodule Canary.Sources.Changes.Typesense.Insert do
  use Ash.Resource.Change

  @error_msg "failed to insert document into index"

  @impl true
  def change(changeset, opts, _context) do
    doc = doc_from_changeset(changeset, opts)

    case Canary.Typesense.insert_document(doc) do
      {:ok, result} ->
        changeset
        |> Ash.Changeset.force_change_attribute(opts[:result_attr], result["id"])

      {:error, e} ->
        changeset |> Ash.Changeset.add_error(field: opts[:result_attr], error: @error_msg)
    end
  end

  def doc_from_changeset(changeset, opts) do
    %Canary.Typesense.Document{
      source: Ash.Changeset.get_argument(changeset, opts[:source_arg]),
      title: Ash.Changeset.get_argument(changeset, opts[:title_arg]),
      content: Ash.Changeset.get_argument(changeset, opts[:content_arg]),
      tags: Ash.Changeset.get_argument(changeset, opts[:tags_arg]),
      meta: %Canary.Typesense.DocumentMetadata{
        url: Ash.Changeset.get_argument(changeset, opts[:url_arg])
      }
    }
  end
end

defmodule Canary.Sources.Changes.Typesense.Destroy do
  use Ash.Resource.Change

  @error_msg "failed to delete document from index"

  @impl true
  def change(changeset, opts, _context) do
    id = Ash.Changeset.get_data(changeset, opts[:id_attr])

    case Canary.Typesense.delete_document(id) do
      {:ok, r} -> changeset
      _ -> changeset |> Ash.Changeset.add_error(error: @error_msg)
    end
  end
end

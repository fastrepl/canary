defmodule Canary.Sources.Changes.Index.Insert do
  use Ash.Resource.Change

  @error_msg "failed to index"

  @impl true
  def change(changeset, opts, _context) do
    doc = doc_from_changeset(changeset, opts)

    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      case Canary.Index.insert_document(doc) do
        {:ok, result} ->
          changeset
          |> Ash.Changeset.force_change_attribute(opts[:index_id_attr], result["id"])

        {:error, _} ->
          changeset
          |> Ash.Changeset.add_error(field: opts[:index_id_attr], error: @error_msg)
      end
    end)
    |> Ash.Changeset.after_action(fn changeset, record ->
      content = changeset |> Ash.Changeset.get_argument(:content)

      %{document_id: record.id, content: content}
      |> Canary.Workers.Summary.new()
      |> Oban.insert()

      {:ok, record}
    end)
  end

  defp doc_from_changeset(changeset, opts) do
    %Canary.Index.Document{
      source: Ash.Changeset.get_argument(changeset, opts[:source_arg]),
      title: Ash.Changeset.get_argument(changeset, opts[:title_arg]),
      content: Ash.Changeset.get_argument(changeset, opts[:content_arg]),
      tags: Ash.Changeset.get_argument(changeset, opts[:tags_arg]),
      meta: %Canary.Index.DocumentMetadata{
        url: Ash.Changeset.get_argument(changeset, opts[:url_arg]),
        titles: Ash.Changeset.get_argument(changeset, opts[:titles_arg])
      }
    }
  end
end

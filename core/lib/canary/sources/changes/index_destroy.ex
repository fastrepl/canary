defmodule Canary.Sources.Changes.Index.Destroy do
  use Ash.Resource.Change

  @impl true
  def atomic(changeset, opts, context) do
    changeset = change(changeset, opts, context)
    {:ok, changeset}
  end

  @impl true
  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _changeset, doc ->
      id = doc |> Map.get(opts[:index_id_attr])

      case Canary.Index.delete_document(id) do
        {:ok, _} -> {:ok, doc}
        {:error, error} -> {:error, error}
      end
    end)
  end
end

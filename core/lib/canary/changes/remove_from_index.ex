defmodule Canary.Change.RemoveFromIndex do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_atom(opts[:index_id_attribute]) do
      {:ok, opts}
    else
      :error
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, record ->
      index_id = Map.get(record, opts[:index_id_attribute])

      case Canary.Index.delete_document(index_id) do
        {:ok, _} -> {:ok, record}
        error -> error
      end
    end)
  end
end

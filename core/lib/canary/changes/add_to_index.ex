defmodule Canary.Change.AddToIndex do
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
    |> Ash.Changeset.force_change_attribute(opts[:index_id_attribute], Ash.UUID.generate())
    |> Ash.Changeset.after_action(fn _, record ->
      case Canary.Index.insert_document(record) do
        {:ok, _} ->
          {:ok, record}

        error ->
          IO.inspect(error)
          error
      end
    end)
  end
end

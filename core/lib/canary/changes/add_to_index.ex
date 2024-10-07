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
  def batch_change(changesets, opts, _context) do
    changesets
    |> Enum.map(
      &Ash.Changeset.force_change_attribute(&1, opts[:index_id_attribute], Ash.UUID.generate())
    )
  end

  @impl true
  def after_batch(changesets_and_results, _opts, _context) do
    records =
      changesets_and_results
      |> Enum.map(fn {_changeset, record} -> record end)

    case Canary.Index.batch_insert_document(records) do
      {:ok, _} ->
        records |> Enum.map(fn record -> {:ok, record} end)

      {:error, error} ->
        records |> Enum.map(fn _ -> {:error, error} end)
    end
  end
end

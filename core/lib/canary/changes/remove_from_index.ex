defmodule Canary.Change.RemoveFromIndex do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_nil(opts[:index_id_attribute]) or is_nil(opts[:source_type]) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def batch_change(changesets, _opts, _context) do
    changesets
  end

  @impl true
  def after_batch(changesets_and_results, opts, _context) do
    source_type = unwrap(opts)[:source_type]
    index_id_attribute = unwrap(opts)[:index_id_attribute]

    records =
      changesets_and_results
      |> Enum.map(fn {_changeset, record} -> record end)

    index_ids =
      records
      |> Enum.map(&Map.get(&1, index_id_attribute))

    case Canary.Index.batch_delete_document(source_type, index_ids) do
      {:ok, %{"num_deleted" => _}} ->
        records |> Enum.map(fn record -> {:ok, record} end)

      {:error, %{"message" => _}} ->
        records |> Enum.map(fn record -> {:ok, record} end)
    end
  end

  # TODO: workaround for {:template, opts}
  defp unwrap(tuple) when is_tuple(tuple), do: elem(tuple, 1)
  defp unwrap(opts), do: opts
end

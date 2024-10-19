defmodule Canary.Index.Trieve.Changes.DeleteGroup do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_nil(opts[:tracking_id_attribute]) do
      {:error, :invalid_opts}
    else
      {:ok, opts}
    end
  end

  @impl true
  def atomic(_changeset, _opts, _context), do: :ok

  @impl true
  def after_batch(changesets_and_results, opts, _context) do
    records =
      changesets_and_results
      |> Enum.map(fn {_changeset, record} -> record end)

    records
    |> Enum.map(&%{"tracking_id" => Map.get(&1, opts[:tracking_id_attribute])})
    |> Enum.map(&Canary.Workers.DeleteTrieveGroup.new(&1))
    |> Oban.insert_all()

    Enum.map(records, &{:ok, &1})
  end
end

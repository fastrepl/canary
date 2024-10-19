defmodule Canary.Index.Trieve.Changes.DeleteChunk do
  use Ash.Resource.Change
  alias Canary.Index.Trieve

  @impl true
  def init(opts) do
    if is_nil(opts[:tracking_id_attribute]) do
      {:error, :invalid_opts}
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
    changesets_and_results
    |> Enum.map(fn {_changeset, record} ->
      record
      |> Map.get(opts[:tracking_id_attribute])
      |> Trieve.Client.delete_chunk()

      # since deleting group also deletes chunks, deleting chunk here might fail.
      # so we don't care if it fails here.
      {:ok, record}
    end)
  end
end

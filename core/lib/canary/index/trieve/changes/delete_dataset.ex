defmodule Canary.Index.Trieve.Changes.DeleteDataset do
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
  def change(changeset, opts, _context) do
    tracking_id = Ash.Changeset.get_attribute(changeset, opts[:tracking_id_attribute])

    changeset
    |> Ash.Changeset.before_transaction(fn changeset ->
      case Trieve.client() |> Trieve.delete_dataset(tracking_id) do
        :ok -> changeset
        {:error, error} -> changeset |> Ash.Changeset.add_error(error)
      end
    end)
  end
end

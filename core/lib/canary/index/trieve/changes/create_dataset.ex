defmodule Canary.Index.Trieve.Changes.CreateDataset do
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
    env = Application.fetch_env!(:canary, :env)
    tracking_id = "#{env}_#{Ecto.UUID.generate()}"

    changeset
    |> Ash.Changeset.force_change_attribute(opts[:tracking_id_attribute], tracking_id)
    |> Ash.Changeset.before_transaction(fn changeset ->
      case Trieve.client() |> Trieve.create_dataset(tracking_id) do
        :ok -> changeset
        {:error, error} -> changeset |> Ash.Changeset.add_error(error)
      end
    end)
  end
end

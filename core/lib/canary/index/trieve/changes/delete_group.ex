defmodule Canary.Index.Trieve.Changes.DeleteGroup do
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
  def atomic(_changeset, _opts, _context), do: :ok

  @impl true
  def after_batch(changesets_and_results, opts, _context) do
    changesets_and_results
    |> Enum.map(fn {_changeset, record} ->
      id = Map.get(record, opts[:tracking_id_attribute])
      {id, record}
    end)
    |> Enum.map(fn {id, record} ->
      case Trieve.Client.delete_group(id) do
        :ok -> {:ok, record}
        {:error, error} -> {:error, error}
      end
    end)
  end
end

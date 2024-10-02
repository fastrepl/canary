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
  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, record ->
      index_id = Map.get(record, opts[:index_id_attribute])

      case Canary.Index.delete_document(opts[:source_type], index_id) do
        {:ok, _} ->
          {:ok, record}

        {:error, %{"message" => message}} ->
          if message =~ "Could not find" do
            {:ok, record}
          else
            {:error, message}
          end

        error ->
          error
      end
    end)
  end
end

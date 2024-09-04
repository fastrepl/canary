defmodule Canary.Change.RemoveCert do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_atom(opts[:host_attribute]) do
      {:ok, opts}
    else
      :error
    end
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  @impl true
  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, record ->
      host = record |> Map.get(opts[:host_attribute])

      case Canary.Fly.delete_certificate(host) do
        {:ok, _} -> {:ok, record}
        error -> error
      end
    end)
  end
end

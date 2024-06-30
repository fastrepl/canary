defmodule Canary.Sources.Changes.Hash do
  use Ash.Resource.Change

  @impl true
  def change(changeset, opts, _context) do
    case Ash.Changeset.get_argument(changeset, opts[:source_attr]) do
      nil ->
        changeset

      value ->
        changeset
        |> Ash.Changeset.force_change_attribute(opts[:hash_attr], :crypto.hash(:sha256, value))
    end
  end
end

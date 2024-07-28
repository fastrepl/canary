defmodule Canary.Sources.Changes.Hash do
  use Ash.Resource.Change

  @impl true
  def change(changeset, opts, _context) do
    sources =
      opts[:source_attrs]
      |> Enum.map(&Ash.Changeset.get_argument(changeset, &1))
      |> Enum.reject(&is_nil/1)

    hash =
      sources
      |> Enum.map(&to_string/1)
      |> Enum.join()
      |> then(&:crypto.hash(:sha256, &1))

    changeset
    |> Ash.Changeset.force_change_attribute(opts[:hash_attr], hash)
  end

  @impl true
  def batch_change(changesets, opts, context) do
    changesets
    |> Enum.map(&change(&1, opts, context))
  end
end

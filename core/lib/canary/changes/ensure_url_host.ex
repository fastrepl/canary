defmodule Canary.Change.EnsureURLHost do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_nil(opts[:input_argument]) or is_nil(opts[:output_attribute]) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    case Ash.Changeset.fetch_argument_or_change(changeset, opts[:input_argument]) do
      :error ->
        changeset

      {:ok, nil} ->
        changeset

      {:ok, "http" <> _ = value} ->
        host = URI.parse(value) |> Map.get(:host)

        changeset
        |> Ash.Changeset.force_change_attribute(opts[:output_attribute], host)

      {:ok, value} ->
        changeset
        |> Ash.Changeset.force_change_attribute(opts[:output_attribute], value)
    end
  end
end

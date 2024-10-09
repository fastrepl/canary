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

      {:ok, value} ->
        changeset
        |> Ash.Changeset.force_change_attribute(opts[:output_attribute], transform(value))
    end
  end

  def transform("http" <> _ = v), do: URI.parse(v).host
  def transform(v) when is_binary(v), do: v
  def transform(v) when is_nil(v), do: v
  def transform(v) when is_list(v), do: Enum.map(v, &transform/1)
end

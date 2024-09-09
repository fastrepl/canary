defmodule Canary.Change.NormalizeURL do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_nil(opts[:input_argument]) or
         (is_nil(opts[:output_attribute]) and is_nil(opts[:output_argument])) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    case Ash.Changeset.fetch_argument_or_change(changeset, opts[:input_argument]) do
      {:ok, value} ->
        url = URI.parse(value) |> to_string() |> String.trim_trailing("/")

        if opts[:output_attribute] do
          Ash.Changeset.force_change_attribute(changeset, opts[:output_attribute], url)
        else
          Ash.Changeset.force_set_argument(changeset, opts[:output_argument], url)
        end

      :error ->
        changeset
    end
  end
end

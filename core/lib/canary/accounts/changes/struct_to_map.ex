defmodule Canary.Accounts.Changes.StructToMap do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_atom(opts[:argument]) do
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
    case Ash.Changeset.fetch_argument(changeset, opts[:argument]) do
      {:ok, value} ->
        Ash.Changeset.force_set_argument(changeset, opts[:argument], convert(value))

      :error ->
        changeset
    end
  end

  defp convert(data) when is_struct(data), do: data |> Map.from_struct() |> convert()
  defp convert(data) when is_map(data), do: data |> Map.new(fn {k, v} -> {k, convert(v)} end)
  defp convert(data) when is_list(data), do: data |> Enum.map(&convert/1)
  defp convert(data), do: data
end

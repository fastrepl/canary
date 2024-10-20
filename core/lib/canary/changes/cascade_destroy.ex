defmodule Canary.Change.CascadeDestroy do
  @moduledoc """
  `Ash.Resource.CascadeDestroy` only works with `relationships`.
  This module exists to work with embedded resources.
  """

  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_nil(opts[:attribute]) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def atomic(_, _, _), do: :ok

  @impl true
  def after_batch(changesets_and_results, opts, _context) do
    chunks =
      changesets_and_results
      |> Enum.flat_map(fn {_, record} -> Map.get(record, opts[:attribute]) end)
      |> transform()

    case Ash.bulk_destroy(chunks, :destroy, %{}, return_errors?: true) do
      %Ash.BulkResult{status: :success} ->
        changesets_and_results
        |> Enum.map(fn {_, record} -> {:ok, record} end)

      %Ash.BulkResult{errors: errors} ->
        changesets_and_results
        |> Enum.map(fn {_, _record} -> {:error, errors} end)
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, record ->
      case Ash.load(record, opts[:attribute]) do
        {:ok, record} ->
          field =
            record
            |> Ash.load!(opts[:attribute])
            |> Map.get(opts[:attribute])

          if is_list(field) do
            case field
                 |> transform()
                 |> Ash.bulk_destroy(:destroy, %{}, return_errors?: true) do
              %{status: :success} -> {:ok, nil}
              %{status: :error, errors: errors} -> {:error, errors}
            end
          else
            field
            |> transform()
            |> Ash.destroy()
          end

        error ->
          error
      end
    end)
  end

  defp transform(data) when is_list(data), do: data |> Enum.map(&transform/1)
  defp transform(%Ash.Union{value: value}), do: value
  defp transform(data), do: data
end

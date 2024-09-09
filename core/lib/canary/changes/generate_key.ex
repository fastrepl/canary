defmodule Canary.Change.GenerateKey do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_nil(opts[:output_attribute]) and is_nil(opts[:output_argument]) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  @impl true
  def change(changeset, opts, _context) do
    length = opts[:length] || 32

    random_string =
      :crypto.strong_rand_bytes(length)
      |> Base.url_encode64()
      |> binary_part(0, length)

    if not is_nil(opts[:output_attribute]) do
      Ash.Changeset.force_change_attribute(
        changeset,
        opts[:output_attribute],
        random_string
      )
    else
      Ash.Changeset.force_set_argument(
        changeset,
        opts[:output_argument],
        random_string
      )
    end
  end
end

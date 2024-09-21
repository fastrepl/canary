defmodule Canary.Validation.URL do
  use Ash.Resource.Validation

  @impl true
  def init(opts) do
    if is_nil(opts[:attribute]) do
      :error
    else
      {:ok, opts}
    end
  end

  @impl true
  def validate(changeset, opts, _context) do
    url =
      changeset
      |> Ash.Changeset.get_attribute(opts[:attribute])

    if is_nil(url) do
      {:error, field: opts[:attribute], message: "empty url"}
    else
      uri = URI.parse(url)

      cond do
        is_nil(uri.scheme) -> {:error, field: opts[:attribute], message: "empty scheme"}
        is_nil(uri.host) -> {:error, field: opts[:attribute], message: "empty host"}
        not (uri.host =~ ".") -> {:error, field: opts[:attribute], message: "invalid host"}
        true -> :ok
      end
    end
  end
end

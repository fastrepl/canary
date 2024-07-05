defmodule Canary.Sources.Calculations.PathToUrl do
  use Ash.Resource.Calculation

  @impl true
  def init(opts), do: {:ok, opts}

  @impl true
  def calculate(records, _opts, _args) do
    records
    |> Enum.map(fn doc ->
      case doc.source.type do
        :docusaurus ->
          base = "/docs"
          file = doc.absolute_path |> Path.relative_to(doc.source.base_path) |> Path.rootname()

          URI.new!(doc.source.base_url)
          |> URI.merge(Path.join(base, file))
          |> URI.to_string()

        _ ->
          "UNKNOWN"
      end
    end)
  end
end

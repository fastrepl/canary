defmodule Canary.Sources.OpenAPI.FetcherResult do
  defstruct [:schema, :served_url, :served_as]

  @type t :: %__MODULE__{
          schema: OpenApiSpex.OpenApi.t(),
          served_url: String.t(),
          served_as: atom()
        }
end

defmodule Canary.Sources.OpenAPI.Fetcher do
  alias Canary.Sources.OpenAPI

  def run(%OpenAPI.Config{} = config) do
    with {:ok, %Req.Response{status: 200, body: map}} <- Req.get(config.source_url),
         schema = OpenApiSpex.schema_from_map(map) do
      {:ok,
       %OpenAPI.FetcherResult{
         schema: schema,
         served_url: config.source_url,
         served_as: config.served_as
       }}
    end
  end
end

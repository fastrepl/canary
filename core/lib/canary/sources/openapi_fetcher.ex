defmodule Canary.Sources.OpenAPI.FetcherResult do
  defstruct [:schema]
  @type t :: %__MODULE__{schema: OpenApiSpex.OpenApi.t()}
end

defmodule Canary.Sources.OpenAPI.Fetcher do
  alias Canary.Sources.OpenAPI

  def run(%OpenAPI.Config{source_url: url}) do
    with {:ok, %Req.Response{status: 200, body: map}} <- Req.get(url),
         schema = OpenApiSpex.schema_from_map(map) do
      {:ok, %OpenAPI.FetcherResult{schema: schema}}
    end
  end
end

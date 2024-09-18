defmodule Canary do
  def rest_client(opts \\ []) do
    Req.new(opts)
  end

  def graphql_client(opts \\ []) do
    Req.new(opts)
    |> AbsintheClient.attach()
    |> Req.Request.register_options([:graphql])
  end
end

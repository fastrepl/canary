defmodule Canary do
  def rest_client(opts \\ []) do
    Req.new(opts)
    |> attach_otel()
  end

  def graphql_client(opts \\ []) do
    Req.new(opts)
    |> attach_otel()
    |> AbsintheClient.attach()
    |> Req.Request.register_options([:graphql])
  end

  defp attach_otel(req) do
    req
    |> OpentelemetryReq.attach(
      propagate_trace_ctx: true,
      no_path_params: true
    )
  end
end

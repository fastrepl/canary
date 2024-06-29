defmodule Canary do
  use Tracing

  def rest_client(opts \\ []) do
    Req.new(opts)
    |> attach_otel()
  end

  defp attach_otel(req) do
    req
    |> OpentelemetryReq.attach(
      propagate_trace_ctx: true,
      no_path_params: true
    )
    |> Req.Request.register_options([:otel_attrs])
    |> Req.Request.append_request_steps(
      otel_attrs: fn req ->
        attrs = req.options |> Map.get(:otel_attrs, %{})
        for {k, v} <- attrs, do: Tracing.set_attribute(k, v)

        req
      end
    )
  end
end

defmodule Canary.Tracing do
  defdelegate current_ctx(), to: OpenTelemetry.Ctx, as: :get_current
  defdelegate attach_ctx(ctx), to: OpenTelemetry.Ctx, as: :attach
end

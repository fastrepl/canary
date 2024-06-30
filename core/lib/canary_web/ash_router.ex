defmodule CanaryWeb.AshRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["Canary.Sources"])],
    open_api: "/openapi"
end

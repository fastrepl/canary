defmodule CanaryWeb.CORSRouter do
  use Corsica.Router,
    allow_credentials: false,
    allow_headers: ["Authorization", "Content-Type"],
    origins: {CanaryWeb.CORSRouter, :is_allowed_origin?, []}

  def is_allowed_origin?(_conn, _origin), do: true

  resource "/api/v1/*"
end

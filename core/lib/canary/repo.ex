defmodule Canary.Repo do
  use AshPostgres.Repo, otp_app: :canary

  def min_pg_version(), do: %Version{major: 16, minor: 0, patch: 0}

  def installed_extensions do
    ["uuid-ossp", "citext", "ash-functions"]
  end

  def default_options(_atom) do
    [
      telemetry_options: [
        _appsignal_current_span: Appsignal.Tracer.current_span()
      ]
    ]
  end
end

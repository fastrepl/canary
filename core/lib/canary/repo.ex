defmodule Canary.Repo do
  use AshPostgres.Repo, otp_app: :canary

  def installed_extensions do
    ["uuid-ossp", "citext", "ash-functions"]
  end
end

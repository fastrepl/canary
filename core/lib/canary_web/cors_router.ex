defmodule CanaryWeb.CORSRouter do
  use Corsica.Router,
    max_age: 300,
    allow_credentials: false,
    allow_headers: ["Authorization", "Content-Type"],
    origins: {CanaryWeb.CORSRouter, :is_allowed_origin?, []}

  def is_allowed_origin?(_conn, origin) do
    %URI{host: host} = URI.parse(origin)
    host in hosts()
  end

  defp hosts() do
    Cachex.fetch!(:cache, :origin, fn _ ->
      hosts = Canary.Accounts.Key.allowed_hosts!()
      {:commit, hosts, expire: :timer.seconds(15)}
    end)
  end

  resource "/api/v1/*"
end

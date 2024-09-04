defmodule CanaryWeb.Plug.Subdomain do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(default), do: default

  @impl true
  def call(conn, router) do
    IO.inspect(conn.host)
    IO.inspect(conn.headers)

    case get_subdomain(conn.host) do
      subdomain when byte_size(subdomain) > 0 ->
        conn
        |> put_private(:subdomain, subdomain)
        |> router.call(router.init({}))
        |> halt()

      _ ->
        conn
    end
  end

  defp get_subdomain(host) do
    root_host = CanaryWeb.Endpoint.config(:url)[:host]
    String.replace(host, ~r/.?#{root_host}/, "")
  end
end

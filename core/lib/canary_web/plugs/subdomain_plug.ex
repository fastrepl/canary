defmodule CanaryWeb.Plug.Subdomain do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(router), do: router

  @impl true
  def call(conn, router) do
    if not subdomain?(conn) do
      conn
    else
      conn
      |> fetch_session()
      |> put_session(:account_id, find_account_id(conn.host))
      |> router.call(router.init({}))
      |> halt()
    end
  end

  defp subdomain?(conn) do
    root_host = CanaryWeb.Endpoint.config(:url)[:host]
    conn.host != root_host
  end

  defp find_account_id(host) do
    root_host = CanaryWeb.Endpoint.config(:url)[:host]

    result =
      if String.ends_with?(host, root_host) do
        name = String.replace(host, ~r/.?#{root_host}/, "")
        Canary.Accounts.Subdomain.find_by_name(name)
      else
        Canary.Accounts.Subdomain.find_by_host(host)
      end

    case result do
      {:ok, %{account: account}} -> account.id
      _ -> nil
    end
  end
end

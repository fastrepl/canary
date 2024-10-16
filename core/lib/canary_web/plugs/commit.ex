defmodule CanaryWeb.Plug.Commit do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: "/commit"} = conn, _opts) do
    conn |> send_resp(200, System.get_env("COMMIT") || "UNKNOWN") |> halt()
  end

  def call(conn, _opts), do: conn
end

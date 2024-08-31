defmodule CanaryWeb.ExperimentalController do
  use CanaryWeb, :controller

  def embed(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<h1>Hello #{conn.private[:subdomain]}</h1>")
  end
end

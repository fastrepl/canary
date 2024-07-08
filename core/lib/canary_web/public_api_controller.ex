defmodule CanaryWeb.PublicApiController do
  use CanaryWeb, :controller
  require Logger

  def analytics(conn, %{"type" => type, "payload" => payload}) do
    res =
      Req.post(
        base_url: "https://api.tinybird.co/v0",
        url: "/events?name=#{type}",
        json: payload
      )

    case res do
      {:ok, %{status: 200}} ->
        conn |> send_resp(200, "") |> halt()

      error ->
        Logger.error("while handling analytics event: #{inspect(error)}")
        conn |> send_resp(200, "") |> halt()
    end
  end

  def search(conn, _) do
    conn |> send_resp(200, "") |> halt()
  end

  def ask(conn, %{"id" => _id, "content" => _content}) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    # {:ok, pid} = Canary.Sessions.find_or_start_session(id)

    # TODO: find client with public key
    # GenServer.call(pid, {:submit, %{query: content}})

    receive_and_send(conn)
  end

  defp receive_and_send(conn) do
    Enum.reduce_while(Stream.repeatedly(fn -> receive_event() end), conn, fn
      {:progress, data}, conn ->
        case chunk(conn, sse_encode(data)) do
          {:ok, conn} -> {:cont, conn}
          {:error, _} -> {:halt, conn}
        end

      {:complete, data}, conn ->
        chunk(conn, sse_encode(data))
        {:halt, conn}

      _, conn ->
        {:cont, conn}
    end)
  end

  defp receive_event() do
    receive do
      event -> event
    after
      10_000 -> {:error, :timeout}
    end
  end

  defp sse_encode(data) do
    "data: #{Jason.encode!(data)}\n\n"
  end
end

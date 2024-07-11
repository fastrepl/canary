defmodule CanaryWeb.PublicApiController do
  use CanaryWeb, :controller
  require Logger

  alias Canary.Interactions.Searcher

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

  def search(conn, %{"query" => query}) do
    with {:ok, client} <- Canary.Interactions.Client.find_web(conn.host),
         {:ok, results} <- Searcher.run(query, Enum.map(client.sources, & &1.id)) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(results))
      |> halt()
    else
      _ ->
        conn
        |> send_resp(422, "")
        |> halt()
    end
  end

  def ask(conn, %{"id" => id, "query" => query}) do
    with {:ok, client} <- Canary.Interactions.Client.find_web(conn.host),
         {:ok, session} <- Canary.Interactions.find_or_create_session(client.account, {:web, id}) do
      conn =
        conn
        |> put_resp_content_type("text/event-stream")
        |> put_resp_header("cache-control", "no-cache")
        |> put_resp_header("connection", "keep-alive")
        |> send_chunked(200)

      here = self()

      Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
        Canary.Interactions.Responder.run(
          session,
          query,
          Enum.map(client.sources, & &1.id),
          fn data -> send(here, data) end
        )
      end)

      receive_and_send(conn)
    else
      _ ->
        conn
        |> send_resp(422, "")
        |> halt()
    end
  end

  defp receive_and_send(conn) do
    Enum.reduce_while(Stream.repeatedly(fn -> receive_event() end), conn, fn
      %{type: :progress} = data, conn ->
        case chunk(conn, sse_encode(data)) do
          {:ok, conn} -> {:cont, conn}
          {:error, _} -> {:halt, conn}
        end

      %{type: :complete} = data, conn ->
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
      60_000 -> {:error, :timeout}
    end
  end

  defp sse_encode(data) do
    "data: #{Jason.encode!(data)}\n\n"
  end
end

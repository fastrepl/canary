defmodule CanaryWeb.OperationsController do
  use CanaryWeb, :controller

  plug :find_client when action in [:search, :ask]
  plug :ensure_valid_host when action in [:search, :ask]

  defp find_client(conn, _opts) do
    err_msg = "no client found with the given key"

    case Canary.Interactions.Client.find_web(conn.params["key"]) do
      {:ok, client} -> conn |> assign(:client, client)
      _ -> conn |> send_resp(401, err_msg) |> halt()
    end
  end

  defp ensure_valid_host(conn, _opts) do
    err_msg = "invalid host"
    host_url = conn.assigns.client.web_host_url

    if Application.get_env(:canary, :env) == :prod and
         conn.host not in [
           host_url,
           "cloud.getcanary.dev",
           "demo.getcanary.dev"
         ] do
      conn |> send_resp(401, err_msg) |> halt()
    else
      conn
    end
  end

  def search(conn, %{"mode" => mode, "query" => query}) do
    results = if mode == "normal", do: noraml_search(query), else: ai_search(query)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(results))
    |> halt()
  end

  defp noraml_search(query) do
    [query]
  end

  defp ai_search(query) do
    [query]
  end

  def ask(conn, %{"id" => id, "query" => query}) do
    client = conn.assigns.client
    {:ok, session} = Canary.Interactions.find_or_create_session(client.account, {:web, id})

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
        client,
        fn data -> send(here, data) end
      )
    end)

    receive_and_send(conn)
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

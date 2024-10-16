defmodule CanaryWeb.OperationsController do
  use CanaryWeb, :controller
  require Ash.Query

  plug :find_sources when action in [:search, :ask]

  defp find_sources(conn, _opts) do
    err_msg = "no client found with the given key"

    with {:ok, token} <- get_token_from_header(conn),
         {:ok, sources} <-
           Canary.Sources.Source
           |> Ash.Query.for_read(:find_with_project_public_key, %{project_public_key: token})
           |> Ash.read() do
      conn
      |> assign(:sources, sources)
      |> assign(:project_id, token)
    else
      _ -> conn |> send_resp(401, err_msg) |> halt()
    end
  end

  defp get_token_from_header(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> :error
    end
  end

  def search(conn, %{"query" => %{"text" => query, "tags" => tags}} = params) do
    case Canary.Searcher.run(conn.assigns.sources, query, tags: tags, cache: cache?()) do
      {:ok, matches} ->
        data = %{
          matches: matches,
          suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
        }

        GenServer.cast(
          Canary.Insights.Processor,
          {:search,
           %{
             query: query,
             project_id: conn.assigns.project_id,
             session_id: params["meta"]["session_id"]
           }}
        )

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(data))
        |> halt()

      {:error, _} ->
        conn
        |> send_resp(500, Jason.encode!(%{}))
        |> halt()
    end
  end

  def ask(conn, %{"query" => %{"text" => query, "tags" => tags}}) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      # https://serverfault.com/a/801629
      |> put_resp_header("x-accel-buffering", "no")
      |> send_chunked(200)

    here = self()

    Task.start_link(fn ->
      Canary.Interactions.Responder.run(
        conn.assigns.sources,
        query,
        fn data -> send(here, data) end,
        tags: tags,
        cache: cache?()
      )
    end)

    receive_and_send(conn)
  end

  defp receive_and_send(conn) do
    Stream.repeatedly(fn -> receive_event() end)
    |> Enum.reduce_while(conn, fn
      {:delta, data}, conn when is_binary(data) ->
        chunk(conn, sse_encode(data))
        {:cont, conn}

      {:done, _data}, conn ->
        {:halt, conn}

      {:error, _}, conn ->
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
    "data: #{data}\r\n\r\n"
  end

  defp cache?(), do: Application.get_env(:canary, :env) == :prod
end

defmodule CanaryWeb.Interface.Controller do
  use CanaryWeb, :controller
  require Ash.Query

  plug :rate_limit when action in [:search, :ask]
  plug :find_project when action in [:search, :ask]

  defp rate_limit(conn, _opts) do
    with {:ok, token} <- get_token_from_header(conn),
         {:allow, _count} <- Hammer.check_rate(token, 60_000, 6000) do
      conn
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(429, Jason.encode!(%{message: "rate limit exceeded"}))
        |> halt()
    end
  end

  defp find_project(conn, _opts) do
    err_msg = "no client found with the given key"

    with {:ok, token} <- get_token_from_header(conn),
         {:ok, project} <-
           Canary.Accounts.Project
           |> Ash.Query.filter(public_key == ^token)
           |> Ash.read_one() do
      conn |> assign(:project, project)
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
    try do
      matches =
        conn.assigns.project
        |> Canary.Interface.Search.run!(query, tags: tags, cache: cache?())

      data = %{
        matches: matches,
        suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
      }

      :ok =
        GenServer.cast(
          Canary.Interactions.UsageExporter,
          {:search, %{project_id: conn.assigns.project.id}}
        )

      :ok =
        GenServer.cast(
          Canary.Interactions.QueryExporter,
          {:search,
           %{
             query: query,
             project_id: conn.assigns.project.id,
             session_id: params["meta"]["session_id"]
           }}
        )

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(data))
      |> halt()
    rescue
      error ->
        Sentry.capture_exception(error, stacktrace: __STACKTRACE__)

        empty = %{
          matches: [],
          suggestion: %{questions: []}
        }

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(empty))
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
      Canary.Interface.Ask.run(
        conn.assigns.project,
        query,
        fn data -> send(here, data) end,
        tags: tags,
        cache: cache?()
      )
    end)

    :ok =
      GenServer.cast(
        Canary.Interactions.UsageExporter,
        {:ask, %{project_id: conn.assigns.project.id}}
      )

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

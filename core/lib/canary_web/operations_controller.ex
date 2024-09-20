defmodule CanaryWeb.OperationsController do
  use CanaryWeb, :controller

  plug :find_key when action in [:search, :ask]
  plug :ensure_valid_host when action in [:search, :ask]

  defp find_key(conn, _opts) do
    err_msg = "no client found with the given key"

    with {:ok, token} <- get_token_from_header(conn),
         {:ok, key} <- Canary.Accounts.Key.find(token) do
      conn |> assign(:key, key)
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

  defp ensure_valid_host(conn, _opts) do
    err_msg = "invalid host"

    %Ash.Union{
      type: :public,
      value: %Canary.Accounts.PublicKeyConfig{} = config
    } = conn.assigns.key.config

    if Application.get_env(:canary, :env) == :prod and
         conn.host not in [config.allowed_host, "getcanary.dev", "cloud.getcanary.dev"] do
      conn |> send_resp(401, err_msg) |> halt()
    else
      conn
      |> assign(:current_account, conn.assigns.key.account)
    end
  end

  def search(conn, %{"query" => query, "sources" => sources}) do
    sources = find_sources(conn, sources)

    case Canary.Searcher.run(sources, query, cache: cache?()) do
      {:ok, matches} ->
        data = %{
          matches: matches,
          suggestion: %{questions: Canary.Query.Sugestor.run!(query)}
        }

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

  def ask(conn, %{"query" => query, "sources" => sources}) do
    sources = find_sources(conn, sources)

    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    here = self()

    Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
      Canary.Interactions.Responder.run(
        sources,
        query,
        fn data -> send(here, data) end,
        cache: cache?()
      )
    end)

    receive_and_send(conn)
  end

  defp find_sources(conn, source_names) do
    conn.assigns.current_account.sources
    |> Enum.filter(fn source ->
      length(source_names) == 0 || Enum.any?(source_names, &(source.name == &1))
    end)
  end

  defp receive_and_send(conn) do
    Enum.reduce_while(Stream.repeatedly(fn -> receive_event() end), conn, fn
      %{type: :references} = data, conn ->
        chunk(conn, sse_encode(data))
        {:cont, conn}

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

  defp cache?(), do: Application.get_env(:canary, :env) == :prod
end

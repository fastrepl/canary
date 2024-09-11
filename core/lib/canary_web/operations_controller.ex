defmodule CanaryWeb.OperationsController do
  use CanaryWeb, :controller

  plug :find_key when action in [:search, :ask, :feedback_page]
  plug :ensure_valid_host when action in [:search, :ask, :feedback_page]

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

  defp fingerprint(conn) do
    ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    user_agent = get_req_header(conn, "user-agent") |> Enum.at(0)
    current_date = Date.utc_today() |> Date.to_string()

    (ip <> user_agent <> current_date)
    |> then(&:crypto.hash(:md5, &1))
    |> Base.encode16(case: :lower)
  end

  defp remove_extension(path) do
    path
    |> String.replace(~r/\.html$/, "")
  end

  defp ensure_trailing_slash(path) do
    case String.ends_with?(path, "/") do
      true -> path
      false -> path <> "/"
    end
  end

  def feedback_page(conn, %{"url" => url, "score" => score}) do
    %URI{host: host, path: path} = URI.parse(url)
    path = path |> remove_extension() |> ensure_trailing_slash()

    if host == "localhost" do
      conn
      |> send_resp(200, "")
      |> halt()
    end

    data = %Canary.Analytics.FeedbackPage{
      host: host,
      path: path,
      score: score,
      account_id: conn.assigns.client.account.id,
      fingerprint: fingerprint(conn)
    }

    case Canary.Analytics.ingest("feedback_page", data) do
      {:ok, _} ->
        conn
        |> send_resp(200, "")
        |> halt()

      error ->
        conn
        |> send_resp(500, Jason.encode!(%{error: error}))
        |> halt()
    end
  end

  def search(conn, %{"query" => query, "sources" => sources}) do
    sources =
      conn.assigns.current_account.sources
      |> Enum.filter(fn source ->
        length(sources) == 0 || Enum.any?(sources, &(source.name == &1))
      end)

    case Canary.Searcher.run(sources, query, cache: cache?()) do
      {:ok, data} ->
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

  def ask(conn, %{"id" => _, "query" => query} = params) do
    client = conn.assigns.client

    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    here = self()

    Task.Supervisor.start_child(Canary.TaskSupervisor, fn ->
      Canary.Interactions.Responder.run(
        query,
        params["pattern"],
        client,
        fn data -> send(here, data) end
      )
    end)

    receive_and_send(conn)
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

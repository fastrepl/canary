defmodule CanaryWeb.Interface.Controller do
  use CanaryWeb, :controller
  require Ash.Query

  @canary_id_header "x-canary-operation-id"

  plug :rate_limit when action in [:search, :ask]
  plug :set_operation_id when action in [:search, :ask]
  plug :find_project when action in [:search, :ask]
  plug :prevent_free_plan when action in [:ask]

  defp set_operation_id(conn, _opts) do
    conn |> put_resp_header(@canary_id_header, Ecto.UUID.generate())
  end

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
    action = Phoenix.Controller.action_name(conn)

    err_msg = "no project found with the given key"

    with {:ok, token} <- get_token_from_header(conn),
         {:ok, project} <-
           Canary.Accounts.Project
           |> Ash.Query.filter(public_key == ^token)
           |> wrap_project_query(action)
           |> Ash.read_one(not_found_error?: true) do
      conn |> assign(:project, project)
    else
      _ -> conn |> send_resp(401, err_msg) |> halt()
    end
  end

  defp prevent_free_plan(conn, _opts) do
    err_msg = "can not access this with free plan"

    cond do
      Application.get_env(:canary, :env) != :prod ->
        conn

      conn.host == "cloud.getcanary.dev" ->
        conn

      not Canary.Membership.can_use_ask?(conn.assigns.project.account) ->
        conn |> send_resp(403, err_msg) |> halt()

      true ->
        conn |> send_resp(403, err_msg) |> halt()
    end
  end

  defp wrap_project_query(query, action) do
    source_query =
      Canary.Sources.Source
      |> Ash.Query.select([:id])

    billing_query =
      Canary.Accounts.Billing
      |> Ash.Query.select([:id])
      |> Ash.Query.load(:membership)

    account_query =
      Canary.Accounts.Account
      |> Ash.Query.select([:id])
      |> Ash.Query.load(billing: billing_query)

    if action == :search do
      query
      |> Ash.Query.load(sources: source_query)
    else
      query
      |> Ash.Query.load(sources: source_query, account: account_query)
    end
  end

  defp get_token_from_header(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> :error
    end
  end

  def event(conn, %{"type" => "navigate", "payload" => %{"id" => id, "url" => url}}) do
    :ok =
      GenServer.cast(
        Canary.Interactions.QueryExporter,
        {:navigate, %{id: id, url: url}}
      )

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{}))
    |> halt()
  end

  def search(conn, %{"query" => %{"text" => query, "tags" => tags}} = params) do
    try do
      matches =
        Canary.Interface.Search.run!(
          conn.assigns.project,
          query,
          tags: tags,
          cache: cache?(),
          source_ids: Enum.map(conn.assigns.project.sources, & &1.id)
        )

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
             id: get_resp_header(conn, @canary_id_header),
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
      try do
        {:ok, completion} =
          Canary.Interface.Ask.run(
            conn.assigns.project,
            query,
            &send(here, {:delta, &1}),
            tags: tags,
            cache: cache?(),
            source_ids: Enum.map(conn.assigns.project.sources, & &1.id)
          )

        send(here, {:done, completion})
      rescue
        exception ->
          send(here, {:error, exception})
          Sentry.capture_exception(exception, stacktrace: __STACKTRACE__)
      end
    end)

    :ok =
      GenServer.cast(
        Canary.Interactions.UsageExporter,
        {:ask, %{project_id: conn.assigns.project.id}}
      )

    receive_and_send(conn)
  end

  defp receive_and_send(conn) do
    receive do
      {:delta, data} when is_binary(data) ->
        case chunk(conn, sse_encode(data)) do
          {:ok, conn} -> receive_and_send(conn)
          _ -> conn
        end

      {:done, _data} ->
        conn

      {:error, _} ->
        conn
    after
      5_000 ->
        conn
    end
  end

  defp sse_encode(data) do
    "data: #{data}\r\n\r\n"
  end

  defp cache?(), do: Application.get_env(:canary, :env) == :prod
end

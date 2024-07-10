defmodule CanaryWeb.Plugs.LoadAccountFromUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil -> conn |> assign(:current_account, nil)
      user -> conn |> assign(:current_account, current_account(user))
    end
  end

  defp current_account(user) do
    accounts =
      user
      |> Ash.load!(accounts: [:sources, :clients])
      |> Map.get(:accounts)

    if length(accounts) > 0, do: Enum.at(accounts, 0), else: nil
  end
end

defmodule CanaryWeb.Plugs.GithubWebhook do
  @behaviour Plug

  require Logger

  import Plug.Conn
  alias Plug.Conn

  @impl true
  def init(opts) do
    path_info = String.split(opts[:at], "/", trim: true)

    opts
    |> Enum.into(%{})
    |> Map.put_new(:path_info, path_info)
  end

  @impl true
  def call(
        %Conn{method: "POST", path_info: path_info} = conn,
        %{path_info: path_info, handler: handler}
      ) do
    with [event] <- get_req_header(conn, "x-github-event"),
         {:ok, body, conn} <- read_body(conn),
         {:ok, params} <- Jason.decode(body),
         :ok <- handle_event!(handler, event, params) do
      conn |> send_resp(200, "") |> halt()
    else
      error ->
        Logger.error("while handling github webhook: #{inspect(error)}")
        conn |> send_resp(200, "") |> halt()
    end
  end

  @impl true
  def call(conn, _), do: conn

  defp handle_event!(handler, event, params) do
    case apply(handler, :handle_event, [event, params]) do
      :ok -> :ok
      {:ok, _} -> :ok
      {:error, error} -> {:error, error}
      _ -> :error
    end
  end
end

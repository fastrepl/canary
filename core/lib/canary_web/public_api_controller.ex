defmodule CanaryWeb.PublicApiController do
  use CanaryWeb, :controller
  require Logger
  require Ash.Query

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
    case Canary.Interactions.Client.find_web(conn.host) do
      {:error, _} ->
        conn |> send_resp(401, "") |> halt()

      {:ok, client} ->
        source_ids = client.sources |> Enum.map(& &1.id)

        chunks =
          Canary.Sources.Chunk
          |> Ash.Query.filter(document.source_id in ^source_ids)
          |> Ash.Query.for_read(:fts_search, %{text: query})
          |> Ash.Query.limit(10)
          |> Ash.read!()

        ret =
          chunks
          |> Enum.map(fn chunk ->
            %{
              url: chunk.document.url,
              excerpt: chunk.content,
              meta: %{title: chunk.document.title}
            }
          end)

        conn |> send_resp(200, Jason.encode!(ret)) |> halt()
    end
  end

  def ask(conn, %{"id" => id, "query" => query}) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    client = Canary.Interactions.Client.find_web!(conn.host)
    source_ids = client.sources |> Enum.map(& &1.id)

    {:ok, session} = Canary.Interactions.find_or_create_session(client.account, {:web, id})
    Canary.Interactions.Responder.run(%{session: session, source_ids: source_ids, request: query})

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

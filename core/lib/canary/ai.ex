defmodule Canary.AI do
  @callback embedding(map()) :: {:ok, list(any())} | {:error, any()}
  @callback chat(map(), list(any())) :: {:ok, map()} | {:error, any()}

  @embedding_dimensions 384

  def embedding(request) do
    request
    |> Map.put(:model, Application.get_env(:canary, :text_embedding_model))
    |> Map.put(:dimensions, @embedding_dimensions)
    |> impl().embedding()
  end

  def chat(request, opts \\ []), do: impl().chat(request, opts)

  defp impl(), do: Application.get_env(:canary, :ai, Canary.AI.OpenAI)
end

defmodule Canary.AI.OpenAI do
  @behaviour Canary.AI

  use Retry

  defp client() do
    proxy_url = Application.fetch_env!(:canary, :openai_api_base)
    proxy_key = Application.fetch_env!(:canary, :openai_api_key)

    Canary.rest_client(
      base_url: proxy_url,
      headers: [{"Authorization", "Bearer #{proxy_key}"}]
    )
  end

  def embedding(request) do
    resp =
      retry with: exponential_backoff() |> randomize |> cap(1_000) |> expiry(4_000) do
        client()
        |> Req.post(
          url: "/v1/embeddings",
          json: request
        )
      end

    case resp do
      {:ok, %{status: 200, body: %{"data" => data}}} ->
        {:ok, data |> Enum.map(& &1["embedding"])}

      {:ok, data} ->
        {:error, data}

      {:error, error} ->
        {:error, error}
    end
  end

  def chat(request, opts \\ []) do
    opts = Keyword.merge([callback: fn data -> IO.inspect(data) end], opts)
    into = if request[:stream], do: get_handler(opts[:callback]), else: nil

    request =
      request
      |> Map.update!(:messages, &trim/1)
      |> Map.update(:tools, nil, &trim/1)
      |> Map.reject(fn {_k, v} -> is_nil(v) end)

    resp =
      retry with: exponential_backoff() |> randomize |> cap(1_000) |> expiry(4_000) do
        client()
        |> Req.post(
          url: "/v1/chat/completions",
          json: request,
          into: into,
          receive_timeout: opts[:timeout] || 15_000
        )
      end

    case resp do
      {:ok, %{body: %{"choices" => [%{"finish_reason" => "tool_calls", "message" => message}]}}} ->
        {:ok, parse_tool_calls(message)}

      {:ok, %{body: %{"choices" => [%{"delta" => delta}]}}} ->
        {:ok, delta["content"]}

      {:ok, %{body: %{"choices" => [%{"message" => message}]}}} ->
        tool_calls = parse_tool_calls(message)

        if tool_calls != [] do
          {:ok, tool_calls}
        else
          {:ok, message["content"]}
        end

      {:ok, %{body: %{"error" => error}}} ->
        {:error, error}

      {:ok, %{body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}

      _ ->
        {:ok, ""}
    end
  end

  defp parse_tool_calls(message) do
    tool_calls = get_in(message, [Access.key("tool_calls", [])]) || []

    tool_calls
    |> Enum.map(fn %{"function" => f} ->
      %{
        name: f["name"],
        args: Jason.decode!(f["arguments"])
      }
    end)
  end

  defp get_handler(callback) do
    fn {:data, data}, acc ->
      Enum.each(parse(data), callback)
      {:cont, acc}
    end
  end

  defp parse(chunk) do
    chunk
    |> String.split("data: ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&decode/1)
    |> Enum.reject(&is_nil/1)
  end

  defp decode(""), do: nil
  defp decode("[DONE]"), do: nil

  defp decode(data) do
    case Jason.decode(data) do
      {:ok, r} -> r
      _ -> nil
    end
  end

  def trim(data) when is_list(data), do: Enum.map(data, &trim/1)

  def trim(data) when is_map(data) do
    data |> Map.new(fn {k, v} -> {k, trim(v)} end)
  end

  def trim(data) when is_binary(data), do: String.trim(data)
  def trim(data), do: data
end

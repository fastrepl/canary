defmodule Canary.Analytics do
  @callback ingest(source :: atom(), data :: any()) :: {:ok, any()} | {:error, any()}
  @callback query(source :: atom(), args :: any()) :: {:ok, any()} | {:error, any()}

  def ingest(_, []), do: :ok

  def ingest(source, data), do: impl().ingest(source, data)
  def query(source, args), do: impl().query(source, args)

  defp impl(), do: Application.get_env(:canary, :analytics, Canary.Analytics.Tinybird)
end

defmodule Canary.Analytics.Tinybird do
  defp client() do
    base_url = Application.get_env(:canary, :tinybird) |> Keyword.fetch!(:base_url)
    api_key = Application.get_env(:canary, :tinybird) |> Keyword.fetch!(:api_key)

    Canary.rest_client(
      base_url: base_url,
      headers: [{"Authorization", "Bearer #{api_key}"}]
    )
  end

  def ingest(source, data) when is_list(data) do
    data =
      data
      |> transform_data()
      |> Enum.map(&Jason.encode!/1)
      |> Enum.join("\n")

    case client() |> Req.post(url: "/v0/events?name=#{source}", body: data) do
      {:ok, resp} ->
        handle_ingest_response(resp)

      error ->
        error
    end
  end

  def ingest(source, data) when is_map(data) do
    data = transform_data(data)

    case client() |> Req.post(url: "/v0/events?name=#{source}", json: data) do
      {:ok, resp} -> handle_ingest_response(resp)
      error -> error
    end
  end

  defp transform_data(data) when is_list(data), do: Enum.map(data, &transform_data/1)

  defp transform_data(data) when is_map(data) do
    data
    |> Enum.map(fn
      {key, %DateTime{} = value} -> {key, DateTime.to_iso8601(value)}
      {key, value} -> {key, value}
    end)
    |> Map.new()
  end

  defp handle_ingest_response(%Req.Response{} = resp) do
    case resp do
      %{status: 202, body: %{"quarantined_rows" => rows}} when rows > 0 ->
        {:error, :quarantined}

      %{status: 202} ->
        :ok

      error ->
        IO.inspect(error)
        error
    end
  end

  def query(source, args) do
    case client() |> Req.post(url: "/v0/pipes/#{source}.json", json: args) do
      {:ok, %{status: 200, body: %{"data" => data}}} -> {:ok, data}
      error -> error
    end
  end
end

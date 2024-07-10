defmodule Canary.Analytics.Tinybird do
  @datasource "web"

  defp client() do
    base_url = Application.get_env(:canary, :tinybird) |> Keyword.fetch!(:base_url)
    api_key = Application.get_env(:canary, :tinybird) |> Keyword.fetch!(:api_key)

    Req.new(
      base_url: base_url,
      headers: [{"Authorization", "Bearer #{api_key}"}]
    )
  end

  def event(data) do
    client()
    |> Req.post(
      url: "/v0/events?name=#{@datasource}",
      json: Map.merge(data, %{"timestamp" => DateTime.to_iso8601(DateTime.utc_now())})
    )
  end
end

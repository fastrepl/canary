defmodule Canary.Req.MetaRefresh do
  def handle({request, response}) do
    with true <- html_response?(response),
         {:ok, {delay, url}} <- extract_meta_refresh(response.body) do
      follow_meta_refresh(request, delay, url)
    else
      _ -> {request, response}
    end
  end

  defp html_response?(response) do
    response
    |> Req.Response.get_header("content-type")
    |> Enum.at(0)
    |> case do
      "text/html" <> _ -> true
      _ -> false
    end
  end

  defp extract_meta_refresh(body) do
    with {:ok, doc} <- Floki.parse_document(body),
         [data] <- Floki.attribute(doc, "meta[http-equiv=refresh]", "content"),
         [delay, url] = String.split(data, ";url=") do
      delay =
        try do
          String.to_integer(delay)
        rescue
          _ -> 0
        end

      {:ok, {delay, url}}
    else
      _ -> :error
    end
  end

  defp follow_meta_refresh(request, delay, url) do
    Process.sleep(delay * 1000)

    request
    |> Map.put(:url, URI.merge(request.url, url))
    |> Req.Request.run_request()
  end
end

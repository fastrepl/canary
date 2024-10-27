defmodule Canary.Req.MetaRefresh do
  def attach(%Req.Request{} = request, _opts \\ []) do
    request
    |> Req.Request.append_response_steps(meta_refresh: &handle/1)
  end

  def handle({request, response}) do
    try do
      if html_response?(response) do
        case extract_meta_refresh(response.body) do
          {:ok, {delay, url}} -> follow_meta_refresh(request, delay, url)
          _ -> {request, response}
        end
      else
        {request, response}
      end
    rescue
      exception ->
        Sentry.capture_exception(exception, stacktrace: __STACKTRACE__)
        {request, response}
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
         {:ok, [delay, url]} = parse_meta_refresh(data) do
      {:ok, {delay, url}}
    else
      _ -> :error
    end
  end

  defp parse_meta_refresh(data) do
    regex = ~r/^\s*(\d+)\s*;\s*url=(.+)$/i

    case Regex.run(regex, data, capture: :all_but_first) do
      [delay, url] ->
        delay =
          case Integer.parse(delay) do
            {n, _} -> n
            :error -> 1
          end

        {:ok, [delay, url]}

      _ ->
        :error
    end
  end

  defp follow_meta_refresh(request, delay, url) do
    Process.sleep(delay * 1000)

    request
    |> Map.put(:url, URI.merge(request.url, url))
    |> Req.Request.run_request()
  end
end

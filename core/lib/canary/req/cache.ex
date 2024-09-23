defmodule Canary.Req.Cache do
  def attach(%Req.Request{} = request, opts \\ []) do
    opts = Keyword.merge([cachex: :cache, ttl: :timer.hours(1)], opts)

    request
    |> Req.Request.register_options([:cachex, :ttl])
    |> Req.Request.merge_options(opts)
    |> Req.Request.append_request_steps(cachex_cache: &request_cache_step/1)
    |> Req.Request.prepend_response_steps(cachex_cache: &response_cache_step/1)
  end

  def handle({request, response}) do
    {request, response}
  end

  defp request_cache_step(%Req.Request{method: :get} = request) do
    key = cache_key(request)

    case :cache |> Cachex.get(key) do
      {:ok, nil} -> request
      {:ok, cached_response} -> {request, cached_response}
    end
  end

  defp request_cache_step(request), do: request

  defp response_cache_step(
         {%Req.Request{method: :get} = request, %Req.Response{status: 200} = response}
       ) do
    key = cache_key(request)
    value = response
    opts = [ttl: request.options[:ttl]]

    case :cache |> Cachex.put(key, value, opts) do
      {:ok, true} -> :ok
      {:error, _error} -> :ok
    end

    {request, response}
  end

  defp response_cache_step(response), do: response

  defp cache_key(request), do: request.url |> to_string() |> String.trim_trailing(".html")
end

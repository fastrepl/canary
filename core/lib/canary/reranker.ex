defmodule Canary.Reranker do
  @callback run(
              query :: String.t(),
              docs :: list(any()),
              opts :: keyword()
            ) :: {:ok, list(any())} | {:error, any()}

  def run(_, _, _ \\ [])
  def run(_, [], _), do: {:ok, []}
  def run(query, docs, opts), do: impl().run(query, docs, opts)

  defp impl(), do: Application.get_env(:canary, :reranker, Canary.Reranker.Noop)
end

defmodule Canary.Reranker.Cohere do
  @behaviour Canary.Reranker

  @model "rerank-english-v3.0"
  @timeout 300
  @retry_interval 50

  use Retry

  def run(query, docs, opts) do
    renderer = opts[:renderer] || fn doc -> doc end
    threshold = opts[:threshold] || 0

    result =
      retry with: constant_backoff(@retry_interval) do
        request(query, docs, renderer)
      end

    case result do
      {:ok, %{status: 200, body: body}} ->
        reranked =
          body["results"]
          |> Enum.sort_by(& &1["relevance_score"], :asc)
          |> Enum.filter(fn %{"relevance_score" => score} -> score > threshold end)
          |> Enum.map(fn %{"index" => i} -> i end)
          |> Enum.reduce([], fn i, acc -> [Enum.at(docs, i) | acc] end)

        {:ok, reranked}

      {:ok, res} ->
        {:error, res}

      {:error, error} ->
        {:error, error}
    end
  end

  defp request(query, docs, renderer) do
    Canary.rest_client()
    |> Req.post(
      base_url: "https://api.cohere.com/v1",
      url: "/rerank",
      headers: [{"Authorization", "Bearer #{Application.fetch_env!(:canary, :cohere_api_key)}"}],
      json: %{
        model: @model,
        query: query,
        documents: Enum.map(docs, &renderer.(&1)),
        return_documents: false
      },
      timeout: @timeout
    )
  end
end

defmodule Canary.Reranker.Jina do
  @behaviour Canary.Reranker

  @model "jina-reranker-v2-base-multilingual"

  use Retry

  def run(query, docs, renderer) do
    threshold = 0

    result =
      retry with: exponential_backoff() |> randomize |> cap(1_000) |> expiry(4_000) do
        request(query, docs, renderer)
      end

    case result do
      {:ok, %{status: 200, body: body}} ->
        reranked =
          body["results"]
          |> Enum.sort_by(& &1["relevance_score"], :asc)
          |> Enum.filter(fn %{"relevance_score" => score} -> score > threshold end)
          |> Enum.map(fn %{"index" => i} -> i end)
          |> Enum.reduce([], fn i, acc -> [Enum.at(docs, i) | acc] end)

        {:ok, reranked}

      {:ok, res} ->
        {:error, res}

      {:error, error} ->
        {:error, error}
    end
  end

  defp request(query, docs, renderer) do
    Canary.rest_client()
    |> Req.post(
      base_url: "https://api.jina.ai/v1",
      url: "/rerank",
      headers: [{"Authorization", "Bearer #{Application.fetch_env!(:canary, :jina_api_key)}"}],
      json: %{
        model: @model,
        query: query,
        documents: Enum.map(docs, &renderer.(&1))
      }
    )
  end
end

defmodule Canary.Reranker.Noop do
  @behaviour Canary.Reranker
  def run(_query, docs, _opts), do: {:ok, docs}
end

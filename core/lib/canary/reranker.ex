defmodule Canary.Reranker do
  @callback run(
              query :: String.t(),
              docs :: list(any()),
              opts :: list(any())
            ) :: {:ok, list(any())} | {:error, any()}

  def run(query, docs, opts \\ []), do: impl().run(query, docs, opts)
  defp impl(), do: Application.get_env(:canary, :reranker, Canary.Reranker.Noop)
end

defmodule Canary.Reranker.Cohere do
  @behaviour Canary.Reranker

  @model "rerank-english-v3.0"

  def run(query, docs, opts) do
    top_n = opts[:top_n] || 5
    threshold = opts[:threshold] || 0

    result =
      Req.post(
        base_url: "https://api.cohere.com/v1",
        url: "/rerank",
        headers: [{"Authorization", "Bearer #{Application.fetch_env!(:canary, :cohere_api_key)}"}],
        json: %{
          model: @model,
          query: query,
          top_n: top_n,
          documents: Enum.map(docs, &Canary.Renderable.render/1),
          return_documents: false
        }
      )

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
end

defmodule Canary.Reranker.Noop do
  @behaviour Canary.Reranker
  def run(_query, docs, _opts), do: {:ok, docs}
end

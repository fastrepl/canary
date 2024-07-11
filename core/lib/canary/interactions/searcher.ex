defmodule Canary.Interactions.Searcher.Result do
  @derive Jason.Encoder
  defstruct [:title, :url, :excerpt]

  @type t :: %__MODULE__{title: String.t(), url: String.t(), excerpt: String.t()}
end

defmodule Canary.Interactions.Searcher do
  alias Canary.Interactions.Searcher

  @callback run(String.t(), list(any())) :: {:ok, list(Searcher.Result.t())} | {:error, any()}
  def run(query, source_ids), do: impl().run(query, source_ids)

  defp impl(), do: Application.get_env(:canary, :searcher, Searcher.Default)
end

defmodule Canary.Interactions.Searcher.Default do
  @behaviour Canary.Interactions.Searcher
  require Ash.Query

  alias Canary.Interactions.Searcher.Result

  def run(query, source_ids) do
    op =
      Canary.Sources.Chunk
      |> Ash.Query.filter(document.source_id in ^source_ids)
      |> Ash.Query.for_read(:fts_search, %{text: query})
      |> Ash.Query.limit(10)
      |> Ash.read()

    case op do
      {:ok, chunks} -> {:ok, transform(chunks)}
      error -> error
    end
  end

  defp transform(chunks) do
    chunks
    |> Enum.map(fn chunk ->
      %Result{
        title: chunk.document.title,
        url: chunk.document.url,
        excerpt: chunk.content
      }
    end)
  end
end

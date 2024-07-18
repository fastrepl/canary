defmodule Canary.Interactions.Searcher.Result do
  @derive Jason.Encoder
  defstruct [:title, :url, :excerpt]

  @type t :: %__MODULE__{title: String.t(), url: String.t(), excerpt: String.t()}
end

defmodule Canary.Interactions.Searcher do
  alias Canary.Interactions.Searcher

  @callback run(String.t(), any()) :: {:ok, list(Searcher.Result.t())} | {:error, any()}
  def run(query, client), do: impl().run(query, client)

  defp impl(), do: Application.get_env(:canary, :searcher, Searcher.Default)
end

defmodule Canary.Interactions.Searcher.Default do
  @behaviour Canary.Interactions.Searcher
  require Ash.Query

  alias Canary.Interactions.Client
  alias Canary.Interactions.Searcher.Result

  @n 20

  def run(query, %Client{account: account, sources: sources}) do
    op =
      Canary.Sources.Chunk
      |> Ash.Query.filter(document.source_id in ^Enum.map(sources, & &1.id))
      |> Ash.Query.for_read(:fts_search, %{text: query})
      |> Ash.Query.limit(@n)
      |> Ash.read()

    case op do
      {:ok, chunks} ->
        Canary.Accounts.Billing.increment_search(account.billing)
        {:ok, transform(chunks)}

      error ->
        error
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

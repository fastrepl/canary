defmodule Canary.Sources.Webpage.FetcherResult do
  alias Canary.Scraper.Item

  defstruct [:url, :html, :items]
  @type t :: %__MODULE__{url: String.t(), html: String.t(), items: list(Item.t())}
end

defmodule Canary.Sources.Webpage.Fetcher do
  alias Canary.Sources.Source
  alias Canary.Sources.Webpage.FetcherResult
  alias Canary.Sources.Webpage.Config

  def run(%Source{config: %Ash.Union{type: :webpage, value: %Config{} = config}}) do
    case Canary.Crawler.run(config) do
      {:ok, stream} ->
        results =
          stream
          |> Stream.map(fn {url, html} ->
            items = Canary.Scraper.run(html)

            if(length(items) == 0,
              do: nil,
              else: %FetcherResult{url: url, html: html, items: items}
            )
          end)
          |> Stream.reject(&is_nil/1)
          |> Enum.to_list()

        {:ok, results}

      error ->
        error
    end
  end
end

defmodule Canary.Sources.Webpage.FetcherResult do
  defstruct [:url, :html]
  @type t :: %__MODULE__{url: String.t(), html: String.t()}
end

defmodule Canary.Sources.Webpage.Fetcher do
  alias Canary.Sources.Webpage.FetcherResult
  alias Canary.Sources.Webpage.Config

  alias Canary.Crawler

  def run(%Config{} = config) do
    url = config.start_urls |> Enum.at(0)

    case Crawler.run(url,
           include_patterns: config.url_include_patterns,
           exclude_patterns: config.url_exclude_patterns
         ) do
      {:ok, results} ->
        results =
          results
          |> Enum.map(fn {url, html} -> %FetcherResult{url: url, html: html} end)

        {:ok, results}

      error ->
        error
    end
  end
end

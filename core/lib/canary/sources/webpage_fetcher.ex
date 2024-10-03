defmodule Canary.Sources.Webpage.FetcherResult do
  alias Canary.Scraper.Item

  defstruct [:url, :html, :tags, :items]

  @type t :: %__MODULE__{
          url: String.t(),
          html: String.t(),
          tags: list(String.t()),
          items: list(Item.t())
        }
end

defmodule Canary.Sources.Webpage.Fetcher do
  alias Canary.Sources.Webpage

  def run(%Webpage.Config{} = config) do
    case Canary.Crawler.run(config) do
      {:ok, stream} ->
        stream =
          stream
          |> Stream.map(fn {url, html} ->
            items = Canary.Scraper.run(html)

            tags =
              config.tag_definitions
              |> Enum.filter(&is_matching_tag?(&1, url))
              |> Enum.map(& &1.name)

            if(length(items) == 0,
              do: nil,
              else: %Webpage.FetcherResult{url: url, html: html, tags: tags, items: items}
            )
          end)
          |> Stream.reject(&is_nil/1)

        {:ok, stream}

      error ->
        error
    end
  end

  defp is_matching_tag?(%Webpage.TagDefinition{} = tag, url) do
    tag.url_include_patterns
    |> Enum.any?(&Canary.Native.glob_match(&1, url))
  end
end

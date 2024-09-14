# TODO: to support multi-start-urls, we need to provide store PID from the outside
# Not sure how to handle "Sitemap" and "Fallback" in the same time

# one clever way of doing it is to pass Store to Sitemap based thing? do not do dupliates.
# To support forum use-case, we need lot more config. (split sitepap <> start-urls..?)
# Do not over-complicate it for now

defmodule Canary.Crawler do
  @callback run(String.t(), opts :: keyword()) :: {:ok, map()} | {:error, any()}
  @modules [Canary.Crawler.Sitemap, Canary.Crawler.Fallback]

  def run(url, config \\ []) do
    @modules
    |> Enum.reduce_while({:error, :failed}, fn module, _acc ->
      case module.run(url, config) do
        {:ok, result} -> {:halt, {:ok, result}}
        _ -> {:cont, {:error, :failed}}
      end
    end)
  end

  def run!(url, config \\ []) do
    {:ok, result} = run(url, config)
    result
  end

  def include?(url, config \\ []) do
    base = url |> URI.parse() |> Map.put(:path, "") |> to_string()
    include_patterns = Keyword.get(config, :include_patterns, ["#{base}/**"])
    exclude_patterns = Keyword.get(config, :exclude_patterns, ["#{base}/**/*.json"])

    cond do
      Enum.any?(exclude_patterns, &Canary.Native.glob_match(&1, url)) ->
        false

      Enum.empty?(include_patterns) ->
        true

      true ->
        Enum.any?(include_patterns, &Canary.Native.glob_match(&1, url))
    end
  end
end

defmodule Canary.Crawler.Sitemap do
  def run(given_url, config) do
    urls =
      given_url
      |> list_sitemaps()
      |> Enum.flat_map(&parse_sitemap/1)
      |> Enum.filter(&Canary.Crawler.include?(&1, config))

    if urls == [] do
      {:error, :not_found}
    else
      map = urls |> Enum.reduce(%{}, &Map.put(&2, &1, fetch_url(&1)))
      {:ok, map}
    end
  end

  def list_sitemaps(url) do
    robots_url = URI.new!(url) |> Map.put(:path, "/robots.txt") |> URI.to_string()
    maybe_sitemap = URI.new!(url) |> Map.put(:path, "/sitemap.xml") |> URI.to_string()

    case Req.new() |> ReqCrawl.Robots.attach() |> Req.get(url: robots_url) do
      {:ok, %{private: %{crawl_robots: %{sitemaps: urls}}}} -> [maybe_sitemap | urls]
      _ -> [maybe_sitemap]
    end
  end

  defp parse_sitemap(sitemap_url) do
    urls =
      case Req.new() |> ReqCrawl.Sitemap.attach() |> Req.get(url: sitemap_url) do
        {:ok, %{private: %{crawl_sitemap: {:sitemap, list}}}} -> list
        {:ok, %{private: %{crawl_sitemap: {:sitemapindex, list}}}} -> list
        _ -> []
      end

    urls
    |> Enum.flat_map(fn url ->
      if String.contains?(url, "sitemap") and String.ends_with?(url, ".xml") do
        parse_sitemap(url)
      else
        [url]
      end
    end)
  end

  defp fetch_url(url) do
    case Req.get(url: url) do
      {:ok, %{status: 200, body: body}} -> body
      _ -> nil
    end
  end
end

defmodule Canary.Crawler.Fallback do
  defmodule Filter do
    @behaviour Crawler.Fetcher.UrlFilter.Spec

    def filter(url, opts) do
      boolean = URI.new!(url).host == opts.host && Canary.Crawler.include?(url, opts.config)
      {:ok, boolean}
    end
  end

  defmodule Scraper do
    @behaviour Crawler.Scraper.Spec

    def scrape(%Crawler.Store.Page{url: url, body: body, opts: opts} = page) do
      opts.store_pid |> Agent.update(&Map.put(&1, normalize(url), body))
      {:ok, page}
    end

    defp normalize(url) do
      url
      |> URI.parse()
      |> Map.put(:query, nil)
      |> Map.put(:fragment, nil)
      |> URI.to_string()
      |> String.replace_trailing("/", "")
    end
  end

  def run(url, config) do
    {:ok, store_pid} = Agent.start_link(fn -> %{} end)

    crawler =
      Crawler.crawl(
        url,
        host: URI.new!(url).host,
        workers: 10,
        interval: 10,
        max_pages: 100 * 100,
        max_depths: 5,
        url_filter: Filter,
        scraper: Scraper,
        store_pid: store_pid,
        user_agent: "Canary (github.com/fastrepl/canary)",
        config: config
      )

    case crawler do
      {:ok, opts} ->
        wait(opts)
        result = store_pid |> Agent.get(fn store -> store end)
        {:ok, result}

      _ ->
        {:error, :failed}
    end
  end

  defp wait(opts, seconds_left \\ 20) do
    cond do
      seconds_left < 0 ->
        Crawler.stop(opts)
        :error

      Crawler.running?(opts) ->
        Process.sleep(1000)
        wait(opts, seconds_left - 1)

      true ->
        :ok
    end
  end
end

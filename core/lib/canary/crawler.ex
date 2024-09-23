defmodule Canary.Crawler do
  @callback run(String.t(), opts :: keyword()) :: {:ok, map()} | {:error, any()}
  @modules [Canary.Crawler.Sitemap, Canary.Crawler.Fallback]

  alias Canary.Sources.Webpage.Config

  def run(%Config{} = config) do
    @modules
    |> Enum.reduce_while({:error, :failed}, fn module, _acc ->
      case module.run(config) do
        {:ok, result} -> {:halt, {:ok, result}}
        _ -> {:cont, {:error, :failed}}
      end
    end)
  end

  def run!(config) do
    {:ok, result} = run(config)
    result
  end

  def include?(url, %Config{} = config) do
    cond do
      Enum.any?(config.url_exclude_patterns, &Canary.Native.glob_match(&1, url)) ->
        false

      Enum.empty?(config.url_include_patterns) ->
        true

      true ->
        Enum.any?(config.url_include_patterns, &Canary.Native.glob_match(&1, url))
    end
  end

  def normalize_url(url) do
    url
    |> URI.parse()
    |> Map.put(:query, nil)
    |> Map.put(:fragment, nil)
    |> URI.to_string()
    |> String.replace_trailing("/", "")
  end
end

defmodule Canary.Crawler.Sitemap do
  alias Canary.Sources.Webpage.Config

  def run(%Config{} = config) do
    urls =
      config.start_urls
      |> Enum.flat_map(&list_sitemaps/1)
      |> Enum.flat_map(&parse_sitemap/1)
      |> Enum.filter(&Canary.Crawler.include?(&1, config))

    if urls == [] do
      {:error, :not_found}
    else
      map =
        urls
        |> Task.async_stream(&{&1, fetch_url(&1)}, max_concurrency: 10)
        |> Enum.reduce(%{}, fn {:ok, {url, body}}, acc ->
          acc |> Map.put(Canary.Crawler.normalize_url(url), body)
        end)

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
    case Req.new()
         |> Canary.Req.MetaRefresh.attach()
         |> Canary.Req.Cache.attach(cachex: :cache, ttl: :timer.minutes(30))
         |> Req.get(url: url) do
      {:ok, %{status: 200, body: body}} -> body
      _ -> nil
    end
  end
end

defmodule Canary.Crawler.Fallback do
  alias Canary.Sources.Webpage.Config

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
      Agent.update(opts.store_pid, fn store ->
        store
        |> Map.put(Canary.Crawler.normalize_url(url), body)
      end)

      {:ok, page}
    end
  end

  def run(%Config{} = config) do
    {:ok, store_pid} = Agent.start_link(fn -> %{} end)

    shared = [
      workers: 20,
      interval: 0,
      max_pages: 2000,
      max_depths: 20,
      url_filter: Filter,
      scraper: Scraper,
      store_pid: store_pid,
      user_agent: "Canary (github.com/fastrepl/canary)",
      config: config
    ]

    config.start_urls
    |> Enum.map(&Crawler.crawl(&1, Keyword.merge(shared, host: URI.new!(&1).host)))
    |> Enum.each(fn
      {:ok, opts} -> wait(opts)
      _ -> {:error, :failed}
    end)

    result = store_pid |> Agent.get(fn store -> store end)
    {:ok, result}
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

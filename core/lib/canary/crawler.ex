defmodule Canary.Crawler do
  @callback run(String.t(), opts :: keyword()) :: {:ok, map()} | {:error, any()}
  @modules [Canary.Crawler.Visitor, Canary.Crawler.Sitemap]

  alias Canary.Sources.Webpage.Config

  def run(%Config{} = config) do
    @modules
    |> Enum.reduce_while({:error, :failed}, fn module, _acc ->
      case module.run(config) do
        {:ok, stream} -> {:halt, {:ok, stream}}
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

  def fetch_url(url) do
    case Req.new()
         |> Canary.Req.MetaRefresh.attach()
         |> Canary.Req.Cache.attach(cachex: :cache, ttl: :timer.minutes(30))
         |> Req.get(url: url) do
      {:ok, %{status: 200, body: body}} -> body
      _ -> nil
    end
  end
end

defmodule Canary.Crawler.Sitemap do
  alias Canary.Crawler
  alias Canary.Sources.Webpage.Config

  def run(%Config{} = config) do
    urls =
      config.start_urls
      |> Enum.flat_map(&list_sitemaps/1)
      |> Enum.flat_map(&parse_sitemap/1)

    if urls == [] do
      {:error, :not_found}
    else
      stream =
        urls
        |> Stream.filter(&Canary.Crawler.include?(&1, config))
        |> Task.async_stream(fn url -> {Crawler.normalize_url(url), Crawler.fetch_url(url)} end,
          ordered: false,
          max_concurrency: 10,
          timeout: 10_000
        )
        |> Stream.filter(&match?({:ok, _}, &1))
        |> Stream.map(fn {:ok, result} -> result end)

      {:ok, stream}
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
end

defmodule Canary.Crawler.Visitor do
  alias Canary.Crawler
  alias Canary.Sources.Webpage.Config

  def run(%Config{} = config) do
    stream =
      config.start_urls
      |> Enum.map(fn url -> Hop.new(url) |> Hop.stream() end)
      |> Stream.concat()
      |> Stream.map(fn {url, %Req.Response{} = respense, _state} ->
        {Crawler.normalize_url(url), respense.body}
      end)
      |> Stream.filter(fn {url, _body} -> Canary.Crawler.include?(url, config) end)

    {:ok, stream}
  end
end

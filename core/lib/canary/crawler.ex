defmodule Canary.Crawler do
  @callback run(String.t()) :: {:ok, list(tuple())} | {:error, any()}
  @modules [Canary.Crawler.Sitemap, Canary.Crawler.Fallback]

  def run(url) do
    @modules
    |> Enum.reduce_while({:error, :failed}, fn module, _acc ->
      case module.run(url) do
        {:ok, result} -> {:halt, {:ok, result}}
        _ -> {:cont, {:error, :failed}}
      end
    end)
  end
end

defmodule Canary.Crawler.Sitemap do
  def run(url) do
    urls =
      Req.new(base_url: url)
      |> ReqCrawl.Sitemap.attach()
      |> Req.get!(url: "/sitemap.xml")
      |> get_in([Access.key(:private), :crawl_sitemap, Access.elem(1)])

    if urls == nil or urls == [] do
      {:error, :not_found}
    else
      pairs =
        urls
        |> Enum.map(&fetch_url/1)
        |> Enum.reject(&is_nil/1)

      {:ok, pairs}
    end
  end

  defp fetch_url(url) do
    case Req.get(url: url) do
      {:ok, %{status: 200, body: body}} -> {url, body}
      _ -> nil
    end
  end
end

defmodule Canary.Crawler.Fallback do
  defmodule Filter do
    @behaviour Crawler.Fetcher.UrlFilter.Spec

    def filter(url, opts) do
      {:ok, URI.new!(url).host == opts.host}
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

  def run(url) do
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
        user_agent: "Canary (github.com/fastrepl/canary)"
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

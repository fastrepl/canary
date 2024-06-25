defmodule Canary.Crawler do
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
        url_filter: Canary.Crawler.Filter,
        scraper: Canary.Crawler.Scraper,
        store_pid: store_pid,
        user_agent: "Canary (github.com/fastrepl/canary)"
      )

    case crawler do
      {:ok, opts} ->
        wait(opts)
        result = store_pid |> Agent.get(fn store -> store end)
        {:ok, result}

      _ ->
        :error
    end
  end

  defp wait(opts, seconds_left \\ 10) do
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

defmodule Canary.Crawler.Filter do
  @behaviour Crawler.Fetcher.UrlFilter.Spec

  def filter(url, opts) do
    {:ok, URI.new!(url).host == opts.host}
  end
end

defmodule Canary.Crawler.Scraper do
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

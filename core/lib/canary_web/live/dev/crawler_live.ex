defmodule CanaryWeb.Dev.CrawlerLive do
  use CanaryWeb, :live_view
  alias Phoenix.LiveView.AsyncResult

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <form class="flex flex-row gap-2" phx-submit="submit">
        <input
          name="url"
          type="url"
          value={@url}
          autocomplete="off"
          placeholder="URL"
          class="input input-bordered w-full"
        />
        <button type="submit" class="btn btn-neutral">Enter</button>
      </form>

      <%= case @urls do %>
        <% %{ok?: true, result: urls} -> %>
          <span class="font-semibold text-xs"><%= Enum.count(urls) %> urls</span>
          <ul class="overflow-x-hidden hover:overflow-auto h-[calc(100vh-170px)]">
            <li :for={url <- urls} class="flex flex-row">
              <.link navigate={"/dev/reader?url=#{URI.encode_www_form(url)}"} class="link link-hover">
                <%= url %>
              </.link>
            </li>
          </ul>
        <% %{failed: true} -> %>
          <span class="font-semibold text-xs">Failed</span>
        <% _ -> %>
          <div class="flex flex-row items-center gap-1">
            <span class="font-semibold text-xs">Loading</span>
            <span class="loading loading-dots loading-xs"></span>
          </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    if params["url"] do
      socket =
        socket
        |> assign(url: params["url"])
        |> assign_async(:urls, fn ->
          urls =
            params["url"]
            |> Canary.Crawler.run!()
            |> Enum.map(&elem(&1, 0))

          {:ok, %{urls: urls}}
        end)

      {:noreply, socket}
    else
      {:noreply, socket |> assign(url: "", urls: AsyncResult.ok([]))}
    end
  end

  def handle_event("submit", %{"url" => url}, socket) do
    {:noreply, socket |> push_patch(to: "/dev/crawler?url=#{url}")}
  end
end

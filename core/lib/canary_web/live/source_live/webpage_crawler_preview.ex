defmodule CanaryWeb.SourceLive.WebpageCrawlerPreview do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.box is_condensed is_scrollable style="max-height: 400px">
        <:header_title class="flex-auto">
          <div class="flex items-center gap-2">
            <span><%= length(@urls) %> found</span>
            <canary-loading-dots :if={@loading} />
          </div>
        </:header_title>
        <:header class="d-flex flex-items-center">
          <Primer.button phx-click="fetch" phx-target={@myself} is_small>
            <Primer.octicon name="sync-16" />
          </Primer.button>
        </:header>

        <%= if length(@urls) == 0 do %>
          <Primer.blankslate></Primer.blankslate>
        <% end %>
        <:row :for={url <- @urls}>
          <.link href={url}>
            <%= url %>
          </.link>
        </:row>
      </Primer.box>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:urls, fn -> [] end)
      |> assign_new(:loading, fn -> false end)
      |> handle_internal_update(assigns)

    {:ok, socket}
  end

  defp handle_internal_update(socket, assigns) do
    if assigns[:url] do
      urls = [assigns[:url] | socket.assigns.urls]
      socket |> assign(:urls, urls)
    else
      socket
    end
  end

  @impl true
  def handle_event("fetch", _params, socket) do
    config = socket.assigns.config

    config = %Canary.Sources.Webpage.Config{
      start_urls: config["start_urls"],
      url_include_patterns: config["url_include_patterns"] || [],
      url_exclude_patterns: config["url_exclude_patterns"] || []
    }

    self = self()
    myself = socket.assigns.myself

    socket =
      socket
      |> assign(:urls, [])
      |> assign(:loading, true)
      |> start_async(:task, fn ->
        {:ok, stream} = Canary.Crawler.run(config)

        stream
        |> Stream.map(&elem(&1, 0))
        |> Stream.each(fn url -> send_update(self, myself, url: url) end)
        |> Enum.to_list()
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_async(:task, {:ok, urls}, socket) do
    socket =
      socket
      |> assign(:loading, false)
      |> assign(:urls, urls)

    {:noreply, socket}
  end

  @impl true
  def handle_async(:task, {:exit, reason}, socket) do
    IO.inspect(reason)

    socket =
      socket
      |> assign(:loading, false)

    {:noreply, socket}
  end
end

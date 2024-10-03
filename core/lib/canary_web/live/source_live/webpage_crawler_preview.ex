defmodule CanaryWeb.SourceLive.WebpageCrawlerPreview do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer
  alias Canary.Sources.Webpage

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.box is_condensed is_scrollable style="max-height: calc(100vh - 200px)">
        <:header_title class="flex-auto">
          <div class="flex items-center gap-1">
            <span><%= length(@items) %> found</span>
            <Primer.animated_ellipsis :if={@loading} />
          </div>
        </:header_title>
        <:header class="d-flex flex-items-center">
          <Primer.button phx-click="fetch" phx-target={@myself} is_small>
            <Primer.octicon name="sync-16" />
          </Primer.button>
        </:header>

        <%= if length(@items) == 0 do %>
          <Primer.blankslate></Primer.blankslate>
        <% end %>
        <:row :for={item <- Enum.sort(@items)}>
          <div class="flex flex-row justify-between">
            <.render_url url={item.url} />
            <div class="flex flex-row gap-2">
              <%= for tag <- item.tags do %>
                <Primer.label is_secondary><%= tag %></Primer.label>
              <% end %>
            </div>
          </div>
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
      |> assign_new(:items, fn -> [] end)
      |> assign_new(:loading, fn -> false end)
      |> handle_internal_update(assigns)

    {:ok, socket}
  end

  defp handle_internal_update(socket, assigns) do
    if assigns[:item] do
      items = [assigns[:item] | socket.assigns.items]
      socket |> assign(:items, items)
    else
      socket
    end
  end

  @impl true
  def handle_event("fetch", _params, socket) do
    config = socket.assigns.config

    config = %Webpage.Config{
      start_urls: config["start_urls"],
      url_include_patterns: config["url_include_patterns"] || [],
      url_exclude_patterns: config["url_exclude_patterns"] || [],
      tag_definitions: config["tag_definitions"] || []
    }

    self = self()
    myself = socket.assigns.myself

    socket =
      socket
      |> assign(:urls, [])
      |> assign(:loading, true)
      |> cancel_async(:task, :rerun)
      |> start_async(:task, fn ->
        {:ok, stream} = Webpage.Fetcher.run(config)

        stream
        |> Stream.map(fn %Webpage.FetcherResult{} = item -> %{url: item.url, tags: item.tags} end)
        |> Stream.each(fn item -> send_update(self, myself, item: item) end)
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
    if reason != :rerun do
      IO.inspect(reason)
    end

    socket =
      socket
      |> assign(:loading, false)

    {:noreply, socket}
  end

  defp render_url(assigns) do
    ~H"""
    <.link href={@url}>
      <span class="opacity-40"><%= URI.parse(@url).host %></span>
      <span><%= URI.parse(@url).path %></span>
    </.link>
    """
  end
end

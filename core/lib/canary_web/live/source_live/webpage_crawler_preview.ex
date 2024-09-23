defmodule CanaryWeb.SourceLive.WebpageCrawlerPreview do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  alias Phoenix.LiveView.AsyncResult

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if length(@urls) == 0 and is_nil(@task_result) do %>
        <.instruction myself={@myself} />
      <% else %>
        <.preview myself={@myself} task_result={@task_result} />
      <% end %>
    </div>
    """
  end

  defp instruction(assigns) do
    ~H"""
    <Primer.blankslate>
      <:heading>
        Test crawler with current configuration
      </:heading>
      <div>
        <p>
          This is a dry run; documents will not be indexed.<br />
          <span class="font-semibold">Save</span> when you're happy with the results.
        </p>
      </div>
      <:action>
        <Primer.button is_primary phx-click="fetch" phx-target={@myself}>
          Get started
        </Primer.button>
      </:action>
    </Primer.blankslate>
    """
  end

  defp preview(assigns) do
    ~H"""
    <.async_result :let={urls} assign={@task_result}>
      <:loading>
        <div class="flex items-center justify-center h-[240px]">
          <Primer.spinner size="24" />
        </div>
      </:loading>
      <:failed :let={_failure}>Failed</:failed>

      <Primer.box is_condensed is_scrollable style="max-height: 400px">
        <:header_title class="flex-auto">
          URL
        </:header_title>
        <:header class="d-flex flex-items-center">
          <Primer.button phx-click="fetch" phx-target={@myself} is_small>
            <Primer.octicon name="sync-16" />
          </Primer.button>
        </:header>
        <:row :for={url <- urls}>
          <.link href={url}>
            <%= url %>
          </.link>
        </:row>
      </Primer.box>
    </.async_result>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:urls, fn -> [] end)
      |> assign(:task_result, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("fetch", _params, socket) do
    config = socket.assigns.config

    config = %Canary.Sources.Webpage.Config{
      start_urls: config["start_urls"],
      url_include_patterns: config["url_include_patterns"],
      url_exclude_patterns: config["url_exclude_patterns"]
    }

    socket =
      socket
      |> assign(:task_result, AsyncResult.loading())
      |> start_async(:task, fn ->
        {:ok, stream} = Canary.Crawler.run(config)
        urls = stream |> Stream.map(&elem(&1, 0)) |> Enum.to_list()
        {:ok, urls}
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_async(:task, {:ok, result}, socket) do
    socket =
      case result do
        {:ok, value} -> socket |> assign(:task_result, AsyncResult.ok(value))
        {:error, error} -> socket |> assign(:task_result, AsyncResult.failed([], error))
      end

    {:noreply, socket}
  end
end

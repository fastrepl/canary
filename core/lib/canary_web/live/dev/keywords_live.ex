defmodule CanaryWeb.Dev.KeywordsLive do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-change="source">
        <Primer.select
          name="source[]"
          options={Enum.map(@sources, & &1.name)}
          is_form_control
          is_multiple
          is_auto_height
        />
      </form>

      <Primer.box is_scrollable style="max-height: 600px; margin-top: 18px">
        <:header>
          <div class="flex items-center justify-between">
            <span><%= length(@keywords) %> Keywords</span>

            <Primer.button
              is_small
              id="copy-keywords"
              aria-label="Copy"
              phx-hook="Clipboard"
              data-clipboard-text={render_keywords(@keywords)}
            >
              <Primer.octicon name="paste-16" />
            </Primer.button>
          </div>
        </:header>
        <:row :for={word <- @keywords}>
          <span><%= word %></span>
        </:row>
      </Primer.box>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    sources =
      Canary.Sources.Source
      |> Ash.Query.filter(not is_nil(overview))
      |> Ash.read!()

    socket =
      socket
      |> assign(sources: sources)
      |> assign(keywords: [])

    {:ok, socket}
  end

  @impl true
  def handle_event("source", %{"source" => sources}, socket) do
    sources =
      socket.assigns.sources
      |> Enum.filter(&(&1.name in sources))

    keywords = Canary.Query.Understander.keywords(sources)

    socket =
      socket
      |> assign(keywords: keywords)

    {:noreply, socket}
  end

  defp render_keywords(keywords) do
    rendered = keywords |> Enum.map(&"\"#{&1}\"") |> Enum.join(",")
    "[#{rendered}]"
  end
end

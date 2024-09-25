defmodule CanaryWeb.Dev.UnderstanderLive do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

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

      <Primer.box is_scrollable style="max-height: 400px; margin-top: 18px">
        <:header>
          <div class="flex items-center justify-between">
            <span><%= length(@total_keywords) %> Keywords</span>

            <Primer.button
              is_small
              id="copy-keywords"
              aria-label="Copy"
              phx-hook="Clipboard"
              data-clipboard-text={render_keywords(@total_keywords)}
            >
              <Primer.octicon name="paste-16" />
            </Primer.button>
          </div>
        </:header>
        <:row :for={word <- @total_keywords}>
          <span><%= word %></span>
        </:row>
      </Primer.box>

      <form class="flex flex-row gap-2 mt-4 items-center" phx-submit="submit">
        <Primer.text_input
          name="query"
          value={@query}
          autocomplete="off"
          placeholder="Query"
          is_full_width
          is_large
        />
        <Primer.button type="submit">Enter</Primer.button>
      </form>

      <div class="flex flex-row gap-1 items-center mt-2">
        <pre class="text-lg"><%= @latency %>ms: <%= Jason.encode!(@predicted_keywords) %></pre>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    sources = Canary.Sources.Source |> Ash.read!()

    socket =
      socket
      |> assign(query: "")
      |> assign(latency: 0)
      |> assign(sources: sources)
      |> assign(selected: [])
      |> assign(total_keywords: [])
      |> assign(predicted_keywords: [])

    {:ok, socket}
  end

  @impl true
  def handle_event("source", %{"source" => sources}, socket) do
    selected =
      socket.assigns.sources
      |> Enum.filter(&(&1.name in sources))

    keywords = Canary.Query.Understander.keywords(selected)

    socket =
      socket
      |> assign(selected: selected)
      |> assign(total_keywords: keywords)

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"query" => query}, socket) do
    now = System.monotonic_time()
    keywords = Canary.Query.Understander.keywords(socket.assigns.selected)
    {:ok, words} = Canary.Query.Understander.run(query, keywords)
    delta = System.monotonic_time() - now

    socket =
      socket
      |> assign(query: query)
      |> assign(result: words)
      |> assign(total_keywords: keywords)
      |> assign(predicted_keywords: words)
      |> assign(latency: System.convert_time_unit(delta, :native, :millisecond))

    {:noreply, socket}
  end

  defp render_keywords(keywords) do
    rendered = keywords |> Enum.map(&"\"#{&1}\"") |> Enum.join(",")
    "[#{rendered}]"
  end
end

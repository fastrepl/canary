defmodule CanaryWeb.Dev.SearcherLive do
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

      <pre class="text-md"><%= @latency %>ms</pre>
      <ul class="text-xs flex flex-col gap-2">
        <li :for={match <- @matches} class="bg-gray-200">
          <pre><%= Jason.encode!(match, pretty: true) %></pre>
        </li>
      </ul>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    sources = Canary.Sources.Source |> Ash.read!()

    socket =
      socket
      |> assign(query: "")
      |> assign(sources: sources)
      |> assign(selected: [])
      |> assign(latency: 0)
      |> assign(matches: [])

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
    {:ok, matches} = Canary.Searcher.run(socket.assigns.selected, query)
    delta = System.monotonic_time() - now

    socket =
      socket
      |> assign(matches: matches)
      |> assign(latency: System.convert_time_unit(delta, :native, :millisecond))

    {:noreply, socket}
  end
end

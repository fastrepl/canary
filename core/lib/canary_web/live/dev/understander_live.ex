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

      <pre class="mt-4 text-lg"><%= Jason.encode!(@result) %></pre>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    sources = Canary.Sources.Source |> Ash.read!()

    socket =
      socket
      |> assign(query: "")
      |> assign(result: [])
      |> assign(sources: sources)
      |> assign(selected: [])

    {:ok, socket}
  end

  @impl true
  def handle_event("source", %{"source" => sources}, socket) do
    selected =
      socket.assigns.sources
      |> Enum.filter(&(&1.name in sources))

    socket =
      socket
      |> assign(selected: selected)

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"query" => query}, socket) do
    keywords = Canary.Query.Understander.keywords(socket.assigns.selected)
    {:ok, words} = Canary.Query.Understander.run(query, keywords)
    {:noreply, socket |> assign(query: query, result: words)}
  end
end

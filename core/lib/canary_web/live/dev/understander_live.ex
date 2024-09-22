defmodule CanaryWeb.Dev.UnderstanderLive do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-change="source">
        <Primer.select name="Source" options={@source_names} is_form_control />
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
    source_names = sources |> Enum.map(& &1.name)
    current_source = sources |> Enum.at(0)

    socket =
      socket
      |> assign(query: "")
      |> assign(result: [])
      |> assign(sources: sources)
      |> assign(source_names: source_names)
      |> assign(current_source: current_source)

    {:ok, socket}
  end

  @impl true
  def handle_event("source", %{"Source" => source_name}, socket) do
    current_source =
      socket.assigns.sources
      |> Enum.find(&(&1.name == source_name))

    socket =
      socket
      |> assign(current_source: current_source)

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"query" => query}, socket) do
    {:ok, words} = Canary.Query.Understander.run([socket.assigns.current_source], query)
    {:noreply, socket |> assign(query: query, result: words)}
  end
end

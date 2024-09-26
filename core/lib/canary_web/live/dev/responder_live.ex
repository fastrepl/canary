defmodule CanaryWeb.Dev.ResponderLive do
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

      <form class="flex flex-row gap-2 my-2 items-center" phx-submit="submit">
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

      <div class="flex flex-col gap-4 mt-2">
        <pre class="bg-gray-200 text-sm"><%= @latency %>ms</pre>
        <Primer.button
          is_small
          id="copy-response"
          aria-label="Copy"
          phx-hook="Clipboard"
          data-clipboard-text={@response}
        >
          <Primer.octicon name="paste-16" />
        </Primer.button>
        <pre id="response-json" phx-hook="PartialJSON" class="text-lg"><%= @response %></pre>

        <Primer.button
          is_small
          id="copy-docs"
          aria-label="Copy"
          phx-hook="Clipboard"
          data-clipboard-text={Ymlr.document!(@docs)}
        >
          <Primer.octicon name="paste-16" />
        </Primer.button>
        <%= for doc <- @docs do %>
          <div class="bg-gray-200 text-lg"><%= Jason.encode!(doc, pretty: true) %></div>
        <% end %>
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
      |> assign(response: "")
      |> assign(docs: [])
      |> assign(sources: sources)
      |> assign(selected: [])
      |> assign(latency: 0)

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
    self = self()
    selected = socket.assigns.selected

    socket =
      socket
      |> assign(query: query)
      |> assign(response: "")
      |> assign(docs: [])
      |> assign(latency: 0)
      |> assign(started_at: System.monotonic_time())
      |> start_async(:task, fn ->
        {:ok, %{docs: docs}} = Canary.Interactions.Responder.run(selected, query, &send(self, &1))
        docs
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{type: :progress, content: content}, socket) do
    socket = socket |> assign(response: socket.assigns.response <> content)

    socket =
      if socket.assigns.latency == 0 do
        delta = System.monotonic_time() - socket.assigns.started_at
        socket |> assign(latency: System.convert_time_unit(delta, :native, :millisecond))
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{type: :complete, content: content}, socket) do
    socket = socket |> assign(response: content)
    {:noreply, socket}
  end

  @impl true
  def handle_async(:task, {:ok, docs}, socket) do
    socket = socket |> assign(docs: docs)
    {:noreply, socket}
  end

  @impl true
  def handle_async(:task, _result, socket) do
    {:noreply, socket}
  end
end

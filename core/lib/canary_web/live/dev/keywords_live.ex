defmodule CanaryWeb.Dev.KeywordsLive do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-change="source">
        <Primer.select name="Source" options={@source_names} is_form_control />
      </form>
      <Primer.box is_scrollable style="max-height: 600px; margin-top: 18px">
        <:header>
          <span><%= length(@current_source.overview.keywords) %> Keywords</span>
        </:header>
        <:row :for={word <- @current_source.overview.keywords}>
          <span><%= word %></span>
        </:row>
      </Primer.box>
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
end

defmodule CanaryWeb.Dev.KeywordsLive do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-change="source">
        <Primer.select name="Source" options={@source_names} is_form_control />
      </form>

      <Primer.box :if={@current_source} is_scrollable style="max-height: 600px; margin-top: 18px">
        <:header>
          <div class="flex items-center justify-between">
            <span><%= length(@current_source.overview.keywords) %> Keywords</span>

            <Primer.button
              is_small
              aria-label="Copy"
              id={"key-#{@current_source.id}"}
              phx-hook="Clipboard"
              data-clipboard-text={keywords_for_copy(@current_source.overview.keywords)}
            >
              <Primer.octicon name="paste-16" />
            </Primer.button>
          </div>
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
    sources =
      Canary.Sources.Source
      |> Ash.Query.filter(not is_nil(overview))
      |> Ash.read!()

    source_names = sources |> Enum.map(& &1.name)

    socket =
      socket
      |> assign(sources: sources)
      |> assign(source_names: source_names)
      |> assign(current_source: nil)

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

  defp keywords_for_copy(keywords) do
    rendered = keywords |> Enum.map(&"\"#{&1}\"") |> Enum.join(",")
    "[#{rendered}]"
  end
end

defmodule CanaryWeb.SourceLive.List do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>
        Source
        <:actions :if={length(@sources) > 0}>
          <Primer.button is_primary phx-click={Primer.open_dialog("source-form")}>
            New
          </Primer.button>
        </:actions>
      </Primer.subhead>

      <Primer.dialog id="source-form" is_backdrop>
        <:header_title>Create a new source</:header_title>
        <:body>
          <.live_component
            id="source-form"
            module={CanaryWeb.SourceLive.Create}
            current_project={@current_project}
          />
        </:body>
      </Primer.dialog>

      <%= if length(@sources) > 0 do %>
        <Primer.box is_spacious>
          <:row
            :for={source <- @sources}
            navigate={~p"/source/#{source.id}"}
            is_hover_gray
            class="no-underline text-semibold"
          >
            <div class="flex flex-row items-center justify-between">
              <div class="flex flex-row gap-2 items-center">
                <span><%= source.name %></span>
                <Primer.branch_name><%= source.config.type %></Primer.branch_name>
              </div>

              <div class="flex flex-row gap-2 items-center">
                <span
                  id={"event-#{source.id}"}
                  phx-hook="TimeAgo"
                  class="invisible text-gray-700 font-light text-xs"
                >
                  Updated <%= source.lastest_event_at %>
                </span>
                <span class="text-gray-500 h-4 w-4 hero-chevron-right-solid"></span>
              </div>
            </div>
          </:row>
        </Primer.box>
      <% else %>
        <Primer.box>
          <Primer.blankslate is_spacious>
            <:heading>
              You don't have any sources yet
            </:heading>
            <p>Operations like search and ask are performed on sources.</p>

            <:action>
              <Primer.button is_primary phx-click={Primer.open_dialog("source-form")}>
                Create source
              </Primer.button>
            </:action>
            <:action>
              <Primer.button is_link href="https://getcanary.dev">Learn more</Primer.button>
            </:action>
          </Primer.blankslate>
        </Primer.box>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = socket |> assign(assigns)

    sources =
      socket.assigns.sources
      |> Ash.load!([:lastest_event_at])
      |> Enum.sort_by(& &1.name)

    {:ok, socket |> assign(sources: sources)}
  end
end

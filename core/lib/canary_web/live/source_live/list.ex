defmodule CanaryWeb.SourceLive.List do
  use CanaryWeb, :live_component

  @impl true
  def render(%{sources: []} = assigns) do
    ~H"""
    <div>
      <div class="flex flex-row justify-between items-center mb-4">
        <%= render_header(assigns) %>
        <.modal id="source-form">
          <.live_component
            id="source-form"
            module={CanaryWeb.SourceLive.Create}
            current_project={@current_project}
            current_account={@current_account}
          />
        </.modal>
      </div>

      <div class="w-full h-[calc(100vh-300px)] bg-gray-100 rounded-sm flex flex-col items-center justify-center">
        <p class="text-lg">
          You don't have any <span class="text-underline">sources</span> yet.
        </p>
        <.button is_primary phx-click={show_modal("source-form")}>
          Create your first source!
        </.button>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row justify-between items-center mb-4">
        <%= render_header(assigns) %>
        <div>
          <.button is_primary phx-click={show_modal("source-form")}>
            New
          </.button>
          <.modal id="source-form">
            <.live_component
              id="source-form"
              module={CanaryWeb.SourceLive.Create}
              current_project={@current_project}
              current_account={@current_account}
            />
          </.modal>
        </div>
      </div>

      <div class="flex flex-col gap-4">
        <div
          :for={source <- @sources}
          class="border rounded-md px-4 py-4 hover:bg-gray-100 cursor-pointer"
          phx-click={JS.navigate(~p"/source/#{source.id}")}
        >
          <div class="flex flex-row items-center justify-between">
            <div class="flex flex-row gap-2 items-center">
              <span class="text-gray-600"><%= source.name %></span>
              <span class="px-1 py-0.5 rounded-md bg-yellow-100"><%= source.config.type %></span>
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
        </div>
      </div>
    </div>
    """
  end

  defp render_header(assigns) do
    ~H"""
    <div>
      <h2>Sources</h2>
      <div>
        <div>
          For more information, please refer to our <a href="https://getcanary.dev/docs">documentation</a>.
        </div>
      </div>
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

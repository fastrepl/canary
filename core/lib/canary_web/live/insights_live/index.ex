defmodule CanaryWeb.InsightLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(%{can_use_insights?: false} = assigns) do
    ~H"""
    <div>
      <h2 class="mb-4">Insights</h2>
      <div class="w-full h-[calc(100vh-300px)] bg-gray-100 rounded-sm flex flex-col items-center justify-center">
        <p class="text-lg">
          You don't have access to <span class="text-underline">Insights</span>.
        </p>
        <p>
          Learn more about our plans <.link navigate={~p"/billing"}>here</.link>.
        </p>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex flex-row justify-between items-center mb-2">
        <h2>Insights</h2>
        <%!-- <div>
          <.button is_primary phx-click={show_modal("insights-config-dialog")}>
            Config
          </.button>

          <.modal id="insights-config-dialog">
            <.live_component
              id="insights-config"
              module={CanaryWeb.InsightLive.Config}
              current_project={@current_project}
            />
          </.modal>
        </div> --%>
      </div>

      <div class="flex flex-col gap-4">
        <div class="flex flex-row">
          <button
            :for={{range, i} <- @ranges |> Enum.with_index()}
            phx-click="set-range"
            phx-value-item={i}
            class={[
              "px-2 py-0.5 border-gray-200 hover:bg-gray-100 text-gray-500",
              range.active && "bg-gray-200 text-gray-800",
              i == 0 && "border-l border-y rounded-l-md",
              i != 0 && i != Enum.count(@ranges) - 1 && "border",
              i == Enum.count(@ranges) - 1 && "border-r border-y rounded-r-md"
            ]}
          >
            <%= range.name %>
          </button>
        </div>

        <.live_component
          id="insights-volume"
          module={CanaryWeb.InsightsLive.Volume}
          days={Enum.find(@ranges, & &1.active).days}
          timezone={@timezone}
          current_project={@current_project}
        />

        <.live_component
          id="insights-volume"
          module={CanaryWeb.InsightsLive.Query}
          timezone={@timezone}
          days={Enum.find(@ranges, & &1.active).days}
          current_project={@current_project}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    can_use_insights? = Canary.Membership.can_use_insights?(socket.assigns.current_account)
    current_project = socket.assigns.current_project |> Ash.load!(:insights_config)

    ranges = [
      %{
        name: "24h",
        active: false,
        days: 1
      },
      %{
        name: "7d",
        active: true,
        days: 7
      },
      %{
        name: "30d",
        active: false,
        days: 30
      }
    ]

    socket =
      socket
      |> assign(can_use_insights?: can_use_insights?)
      |> assign(current_project: current_project)
      |> assign(:ranges, ranges)

    if timezone = get_connect_params(socket)["timezone"] do
      {:ok, assign(socket, timezone: timezone)}
    else
      {:ok, assign(socket, timezone: "UTC")}
    end
  end

  @impl true
  def handle_event("set-range", %{"item" => index}, socket) do
    ranges =
      socket.assigns.ranges
      |> Enum.map(&Map.put(&1, :active, false))
      |> List.update_at(String.to_integer(index), &Map.put(&1, :active, true))

    {:noreply, assign(socket, ranges: ranges)}
  end
end

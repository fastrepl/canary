defmodule CanaryWeb.InsightLive.Index do
  use CanaryWeb, :live_view

  def render(%{can_use_insights?: false} = assigns) do
    ~H"""
    <div class="w-full h-[calc(100vh-200px)] bg-gray-100 rounded-sm flex flex-col items-center justify-center">
      <p class="text-lg">You don't have access to <span class="text-underline">Insights</span>.</p>
      <p>
        Learn more about our plans <.link navigate={~p"/billing"}>here</.link>.
      </p>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex flex-row justify-between items-center mb-4">
        <h2>Insights</h2>
        <div>
          <.button is_primary phx-click={show_modal("insights-config-dialog")}>
            Config
          </.button>

          <%!-- <.modal id="insights-config-dialog">
            <.live_component
              id="insights-config"
              module={CanaryWeb.InsightLive.Config}
              current_project={@current_project}
              quries={if @search_breakdown.result, do: @search_breakdown.result.labels, else: []}
            />
          </.modal> --%>
        </div>
      </div>

      <.live_component
        id="insights-volume"
        module={CanaryWeb.InsightsLive.Volume}
        current_project={@current_project}
      />

      <.live_component
        id="insights-volume"
        module={CanaryWeb.InsightsLive.Query}
        current_project={@current_project}
      />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    can_use_insights? = Canary.Membership.can_use_insights?(socket.assigns.current_account)
    current_project = socket.assigns.current_project |> Ash.load!(:insights_config)

    socket =
      socket
      |> assign(can_use_insights?: can_use_insights?)
      |> assign(current_project: current_project)

    {:ok, socket}
  end
end

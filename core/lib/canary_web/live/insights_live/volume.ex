defmodule CanaryWeb.InsightsLive.Volume do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class={["w-full h-60", if(@search_volume.loading, do: "animate-pulse bg-gray-100")]}>
        <canvas
          :if={!@search_volume.loading}
          id="search-volume"
          phx-hook="BarChart"
          data-title="Search Volume"
          data-labels={Jason.encode!(@search_volume.result.labels)}
          data-points={Jason.encode!(@search_volume.result.points)}
        >
        </canvas>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_async(:search_volume, fn ->
        case Canary.Analytics.query("search_volume", %{project_id: assigns.current_project.id}) do
          {:ok, data} ->
            result = %{
              labels: Enum.map(data, & &1["date"]),
              points: Enum.map(data, & &1["count"])
            }

            {:ok, %{search_volume: result}}
        end
      end)

    {:ok, socket}
  end
end

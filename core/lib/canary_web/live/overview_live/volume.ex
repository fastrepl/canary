defmodule CanaryWeb.OverviewLive.Volume do
  use CanaryWeb, :live_component

  @impl true
  def render(%{search_volume: %{result: %{labels: []}}} = assigns) do
    ~H"""
    <div class={[
      "w-full flex items-center justify-center",
      "h-60 bg-gray-50 p-4 rounded-lg border"
    ]}>
      <p class="text-gray-700 text-md">
        Not enough data to show.
      </p>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "w-full flex items-center justify-center",
      "h-60 bg-gray-50 p-4 rounded-lg",
      if(@search_volume.loading, do: "animate-pulse bg-gray-100", else: "border")
    ]}>
      <canvas
        :if={!@search_volume.loading}
        id="overview-volume"
        phx-hook="BarChart"
        data-title="Search Volume"
        data-labels={Jason.encode!(@search_volume.result.labels)}
        data-points={Jason.encode!(@search_volume.result.points)}
      >
      </canvas>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    project_id = assigns.current_project.id

    socket =
      socket
      |> assign(assigns)
      |> assign_async(:search_volume, fn ->
        case Canary.Analytics.query("search_volume", %{project_id: project_id}) do
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

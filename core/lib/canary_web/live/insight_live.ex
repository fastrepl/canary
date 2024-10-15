defmodule CanaryWeb.InsightLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-col gap-8">
      <h1 class="text-xl font-semibold mb-4">Insights</h1>

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

      <div class={["w-full h-60", if(@search_breakdown.loading, do: "animate-pulse bg-gray-100")]}>
        <canvas
          :if={!@search_breakdown.loading}
          id="search-breakdown"
          phx-hook="BarChart"
          data-title="Search Breakdown"
          data-labels={Jason.encode!(@search_breakdown.result.labels)}
          data-points={Jason.encode!(@search_breakdown.result.points)}
        >
        </canvas>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    project_id = socket.assigns.current_project.public_key

    socket =
      socket
      |> assign_async(:search_volume, fn ->
        case Canary.Analytics.query("search_volume", %{project_id: project_id}) do
          {:ok, data} ->
            labels = Enum.map(data, & &1["date"])
            points = Enum.map(data, & &1["count"])
            {:ok, %{search_volume: %{labels: labels, points: points}}}
        end
      end)
      |> assign_async(:search_breakdown, fn ->
        case Canary.Analytics.query("search_breakdown", %{project_id: project_id}) do
          {:ok, data} ->
            labels = Enum.map(data, & &1["group_leader"])
            points = Enum.map(data, & &1["query_count"])
            {:ok, %{search_breakdown: %{labels: labels, points: points}}}
        end
      end)

    {:ok, socket}
  end
end

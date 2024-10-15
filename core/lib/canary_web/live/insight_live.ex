defmodule CanaryWeb.InsightLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-full">
      <h1 class="text-xl font-semibold mb-4">Insights</h1>

      <div class="mx-auto max-w-7xl grid grid-cols-1 gap-8 lg:grid-cols-2">
        <div class="w-full h-80">
          <canvas
            id="search-breakdown"
            phx-hook="BarChart"
            data-title="Search Breakdown"
            data-labels={Jason.encode!(@labels)}
            data-points={Jason.encode!(@points)}
          >
          </canvas>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    project_id = socket.assigns.current_project.public_key
    {:ok, data} = Canary.Analytics.pipe("search_breakdown", %{project_id: project_id})

    labels = Enum.map(data, & &1["group_leader"])
    points = Enum.map(data, & &1["query_count"])

    socket = assign(socket, labels: labels, points: points)
    {:ok, socket}
  end
end

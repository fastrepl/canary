defmodule CanaryWeb.InsightsLive.Query do
  use CanaryWeb, :live_component

  @impl true
  def render(%{search_breakdown: %{loading: false, result: %{labels: []}}} = assigns) do
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
      "w-full h-60 bg-gray-50 p-4 rounded-lg border",
      if(@search_breakdown.loading, do: "animate-pulse bg-gray-100")
    ]}>
      <canvas
        :if={!@search_breakdown.loading}
        id="insights-breakdown"
        phx-hook="BarChart"
        data-title="Search Breakdown"
        data-labels={Jason.encode!(@search_breakdown.result.labels)}
        data-points={Jason.encode!(@search_breakdown.result.points)}
      >
      </canvas>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    aliases =
      if assigns.current_project.insights_config do
        assigns.current_project.insights_config.aliases || []
      else
        []
      end

    socket =
      socket
      |> assign(assigns)
      |> assign_async(:search_breakdown, fn ->
        case Canary.Analytics.query("search_breakdown", %{project_id: assigns.current_project.id}) do
          {:ok, data} ->
            map =
              data
              |> Enum.reduce(%{}, fn %{"query" => query, "count" => count}, acc ->
                key =
                  aliases
                  |> Enum.find(fn %{members: members} -> query in members end)
                  |> then(fn
                    %{name: name} -> name
                    _ -> query
                  end)

                acc
                |> Map.update(key, count, &(&1 + count))
              end)

            result =
              map
              |> Enum.sort_by(fn {_, count} -> count end, :desc)
              |> Enum.unzip()
              |> then(fn {keys, counts} -> %{labels: keys, points: counts} end)

            {:ok, %{search_breakdown: result}}
        end
      end)

    {:ok, socket}
  end
end

defmodule CanaryWeb.InsightsLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-full">
      <h1 class="text-xl font-semibold mb-4">Insights</h1>

      <h2 class="text-md font-semibold">Feedback</h2>
      <a
        class="underline text-xs text-gray-500"
        href="https://getcanary.dev/docs/cloud/features/feedback.html#per-page"
      >
        getcanary.dev/docs/cloud/features/feedback
      </a>

      <div class="mx-auto max-w-7xl grid grid-cols-1 gap-8 lg:grid-cols-2">
        <div class="w-full h-80">
          <canvas
            id="feedback-page-breakdown-positive"
            phx-hook="BarChart"
            data-title="Positive"
            data-labels={Jason.encode!(@positive.labels)}
            data-points={Jason.encode!(@positive.points)}
            data-counts={Jason.encode!(@positive.counts)}
            class="w-full h-full"
          >
          </canvas>
        </div>

        <div class="w-full h-80">
          <canvas
            id="feedback-page-breakdown-negative"
            phx-hook="BarChart"
            data-title="Negative"
            data-labels={Jason.encode!(@negative.labels)}
            data-points={Jason.encode!(@negative.points)}
            data-counts={Jason.encode!(@negative.counts)}
          >
          </canvas>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account_id = socket.assigns.current_account.id
    {:ok, data} = Canary.Analytics.feedback_page_breakdown(account_id)

    %{positive: positive, negative: negative} =
      data
      |> Enum.reduce(
        %{
          positive: %{labels: [], points: [], counts: []},
          negative: %{labels: [], points: [], counts: []}
        },
        fn %{"path" => path, "mean_score" => score, "total_count" => counts}, acc ->
          field = if score > 0, do: :positive, else: :negative

          acc
          |> Map.update!(field, fn existing ->
            %{
              existing
              | labels: [path | existing.labels],
                points: [score | existing.points],
                counts: [counts | existing.counts]
            }
          end)
        end
      )

    positive =
      positive
      |> Map.update!(:labels, &Enum.reverse/1)
      |> Map.update!(:points, &Enum.reverse/1)

    socket =
      socket
      |> assign(:positive, positive)
      |> assign(:negative, negative)

    {:ok, socket}
  end
end

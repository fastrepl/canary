defmodule CanaryWeb.FeedbackLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-full">
      <div class="mx-auto max-w-7xl grid grid-cols-1 gap-8 lg:grid-cols-2">
        <div class="w-full h-80">
          <h2 class="text-xl font-semibold mb-4">Positive</h2>
          <canvas
            id="feedback-page-breakdown-positive"
            phx-hook="ChartJS"
            data-labels={Jason.encode!(@positive.labels)}
            data-points={Jason.encode!(@positive.points)}
            class="w-full h-full"
          >
          </canvas>
        </div>

        <div class="w-full h-80">
          <h2 class="text-xl font-semibold mb-4">Negative</h2>
          <canvas
            id="feedback-page-breakdown-negative"
            phx-hook="ChartJS"
            data-labels={Jason.encode!(@negative.labels)}
            data-points={Jason.encode!(@negative.points)}
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
        %{positive: %{labels: [], points: []}, negative: %{labels: [], points: []}},
        fn %{"path" => path, "mean_score" => score}, acc ->
          field = if score > 0, do: :positive, else: :negative

          acc
          |> Map.update!(field, fn existing ->
            %{existing | labels: [path | existing.labels], points: [score | existing.points]}
          end)
        end
      )

    socket =
      socket
      |> assign(:positive, positive)
      |> assign(:negative, negative)

    {:ok, socket}
  end
end

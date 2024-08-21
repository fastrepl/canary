defmodule CanaryWeb.FeedbackLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <div class="mx-auto grid max-w-2xl items-center grid-cols-1 grid-rows-1 items-start gap-x-8 gap-y-8 lg:mx-0 lg:max-w-none lg:grid-cols-1">
        <div class="w-full h-80">
          <h2>Positive</h2>
          <canvas
            id="feedback-page-breakdown-positvie"
            phx-hook="ChartJS"
            data-labels={Jason.encode!(@positvie.labels)}
            data-points={Jason.encode!(@positvie.points)}
          >
          </canvas>
        </div>

        <div class="w-full h-80">
          <h2>Negative</h2>
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

    %{positvie: positvie, negative: negative} =
      data
      |> Enum.reduce(
        %{positvie: %{labels: [], points: []}, negative: %{labels: [], points: []}},
        fn %{"path" => path, "mean_score" => score}, acc ->
          field = if score > 0, do: :positvie, else: :negative

          acc
          |> Map.update!(field, fn existing ->
            %{existing | labels: [path | existing.labels], points: [score | existing.points]}
          end)
        end
      )

    socket =
      socket
      |> assign(:positvie, positvie)
      |> assign(:negative, negative)

    {:ok, socket}
  end
end

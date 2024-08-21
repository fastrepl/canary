defmodule CanaryWeb.FeedbackLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <canvas
        id="feedback-page-breakdown"
        phx-hook="ChartJS"
        data-labels={Jason.encode!(@labels)}
        data-points={Jason.encode!(@points)}
      >
      </canvas>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account_id = socket.assigns.current_account.id
    {:ok, data} = Canary.Analytics.feedback_page_breakdown(account_id)

    labels = data |> Enum.map(fn %{"path" => path} -> path end)
    points = data |> Enum.map(fn %{"mean_score" => score} -> score end)

    socket =
      socket
      |> assign(:labels, labels)
      |> assign(:points, points)

    {:ok, socket}
  end
end

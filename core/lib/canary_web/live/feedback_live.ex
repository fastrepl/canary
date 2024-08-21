defmodule CanaryWeb.FeedbackLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <pre><%= @data %></pre>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, data} = Canary.Analytics.feedback_page_breakdown(socket.assigns.current_account.id)
    {:ok, socket |> assign(data: Jason.encode!(data))}
  end
end

defmodule CanaryWeb.SourcesLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Sources</h1>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

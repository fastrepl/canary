defmodule CanaryWeb.ClientsLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Clients</h1>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

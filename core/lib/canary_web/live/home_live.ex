defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Home</h1>
    """
  end

  def mount(_params, _session, socket) do
    sources = Canary.Sources.Source |> Ash.read!()
    {:ok, socket |> assign(sources: sources)}
  end

  def handle_event("1", _, socket) do
    {:noreply, socket}
  end
end

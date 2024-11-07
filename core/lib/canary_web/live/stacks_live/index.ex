defmodule CanaryWeb.StacksLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(%{live_action: :selector} = assigns) do
    ~H"""
    <.live_component id="stacks-selector" module={CanaryWeb.StacksLive.Selector} />
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :selector, _params) do
    socket
  end
end

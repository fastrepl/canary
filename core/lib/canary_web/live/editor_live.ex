defmodule CanaryWeb.EditorLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header />

    <.svelte name="Editor" socket={@socket} props={%{}} />
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

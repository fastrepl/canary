defmodule CanaryWeb.SettingsLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs font-semibold text-md flex flex-row items-center justify-between">
        <ul>
          <li><a>Settings</a></li>
        </ul>
      </div>
    </.content_header>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

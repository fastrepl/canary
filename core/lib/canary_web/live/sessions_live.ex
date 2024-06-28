defmodule CanaryWeb.SessionsLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><a>Sessions</a></li>
        </ul>
      </div>
    </.content_header>

    <div class="mt-4">
      <div class="stats shadow">
        <div class="stat place-items-center">
          <div class="stat-title">Sessions</div>
          <div class="stat-value"><%= @sessions |> length() %></div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    sessions = Canary.Sessions.Session |> Ash.read!()
    {:ok, socket |> assign(sessions: sessions)}
  end
end

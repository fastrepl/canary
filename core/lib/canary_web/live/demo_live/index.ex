defmodule CanaryWeb.DemoLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-c-gray-95">
      <h1 class="text-c-primary-30">
        Demo
      </h1>
      <%= if @slug do %>
        <.live_component id="search" module={CanaryWeb.DemoLive.Search} />
      <% else %>
        <.live_component id="fallback" module={CanaryWeb.DemoLive.Fallback} />
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:canary_color_c, 0.4)
      |> assign(:canary_color_h, 135)

    {:ok, socket}
  end
end

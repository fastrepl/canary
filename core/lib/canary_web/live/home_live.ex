defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= if @sources == [] do %>
      <h2 class="font-semibold">No sources yet</h2>
    <% else %>
      <h2 class="font-semibold">Sources</h2>
      <ul :if={@sources != []}>
        <li :for={source <- @sources}>
          <%= source.name %>
        </li>
      </ul>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    sources = Canary.Sources.Source |> Ash.read!()
    {:ok, socket |> assign(sources: sources)}
  end
end

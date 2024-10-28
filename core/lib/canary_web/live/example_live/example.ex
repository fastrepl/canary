defmodule CanaryWeb.ExampleLive.Example do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-gray-200 py-4 px-6 rounded-md">
      <h2><%= @example.name %></h2>
      <p :if={@example[:description]} class="italic mb-4"><%= @example.description %></p>

      <div class="flex flex-col gap-0 mt-2">
        <div class="text-md mb-2">
          Click below to try it ↓
        </div>
        <%= raw(@example.code) %>
      </div>

      <div class="flex flex-col gap-0 mt-4 text-wrap">
        <p>Actual code to render above ↓</p>
        <code id={@id} phx-hook="Highlight" class="invisible"><%= @example.code %></code>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end

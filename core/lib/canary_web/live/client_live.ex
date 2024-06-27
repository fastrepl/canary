defmodule CanaryWeb.ClientLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><.link navigate={~p"/clients"}>Clients</.link></li>
          <li><a><%= @client.name %></a></li>
        </ul>
      </div>

      <button class="btn btn-sm btn-neutral btn-outline ml-auto" phx-click="delete">
        Delete
      </button>
    </.content_header>

    <div class="mt-8">
      <%= case @client.type do %>
        <% :discord -> %>
          <div class="flex flex-col gap-2">
            <.render_disabled_input name="Discord Server ID" value={@client.discord_server_id} />
            <.render_disabled_input name="Discord Channel ID" value={@client.discord_channel_id} />
          </div>
        <% :web -> %>
          <.render_disabled_input name="Web Base URL" value={@client.web_base_url} />
      <% end %>
    </div>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    client = Canary.Clients.Client |> Ash.get!(id)

    socket =
      socket
      |> assign(client: client)

    {:ok, socket}
  end

  attr :name, :string, default: nil
  attr :value, :string, default: nil

  defp render_disabled_input(assigns) do
    ~H"""
    <label class="form-control w-full max-w-xs">
      <div class="label">
        <span class="label-text"><%= @name %></span>
      </div>
      <input type="text" disabled placeholder={@value} class="input input-bordered w-full max-w-xs" />
    </label>
    """
  end

  def handle_event("delete", _, socket) do
    socket.assigns.client |> Ash.destroy!()
    {:noreply, socket |> push_navigate(to: ~p"/clients")}
  end
end

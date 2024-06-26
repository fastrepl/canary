defmodule CanaryWeb.SourceLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><.link navigate={~p"/sources"}>Sources</.link></li>
          <li><a><%= @source.name %></a></li>
        </ul>
      </div>

      <button class="btn btn-sm btn-neutral btn-outline ml-auto" phx-click="delete">
        Delete
      </button>
    </.content_header>

    <div class="mt-4">
      <div class="stats shadow">
        <div class="stat place-items-center">
          <div class="stat-title">Documents</div>
          <div class="stat-value"><%= @source.num_documents %></div>

          <%= if @source.updated_at do %>
            <div class="stat-desc">
              Last updated at: <.local_time id="source-updated-at" date={@source.updated_at} />
            </div>
          <% else %>
            <div class="stat-desc">Never fetched.</div>
          <% end %>
        </div>

        <div class="stat place-items-center">
          <button class="btn btn-md btn-shadow" phx-click="fetch">
            Fetch
          </button>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    source = Canary.Sources.Source |> Ash.get!(id)

    socket =
      socket
      |> assign(source: source)

    {:ok, socket}
  end

  def handle_event("delete", _, socket) do
    socket.assigns.source |> Ash.destroy!()
    {:noreply, socket |> push_navigate(to: ~p"/sources")}
  end

  def handle_event("fetch", _, socket) do
    %{source_id: socket.assigns.source.id}
    |> Canary.Workers.Fetcher.new()
    |> Oban.insert!()

    socket =
      socket
      |> put_flash(:info, "On it! It will take a few minutes.")
      |> push_navigate(to: ~p"/sources")

    {:noreply, socket}
  end
end

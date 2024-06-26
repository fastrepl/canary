defmodule CanaryWeb.ClientsLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><a>Clients</a></li>
        </ul>
      </div>

      <button class="btn btn-sm btn-neutral ml-auto" onclick="modal.showModal()">
        Add new client
      </button>
    </.content_header>

    <dialog id="modal" class="modal">
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>

      <div class="modal-box flex flex-col">
        <form phx-submit="save" class="flex flex-col gap-2">
          <select name="type" class="select select-bordered w-full">
            <option selected>Discord</option>
          </select>
          <input
            type="text"
            autocomplete="off"
            name="name"
            placeholder="e.g. canary/support"
            class="input input-bordered w-full"
          />
          <input
            type="number"
            name="server_id"
            placeholder="Server ID"
            class="input input-bordered w-full"
          />
          <input
            type="number"
            name="channel_id"
            placeholder="Channel ID"
            class="input input-bordered w-full"
          />

          <div class="flex flex-row gap-2 ml-auto mt-4">
            <button type="button" class="btn" onclick="modal.close()">
              Close
            </button>
            <button type="submit" class="btn btn-neutral" onclick="modal.close()">
              Save
            </button>
          </div>
        </form>
      </div>
    </dialog>

    <table class="table mt-8">
      <thead>
        <tr>
          <th>Type</th>
          <th>Name</th>
          <th>Linked sources</th>
          <th>Created at</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for client <- @clients do %>
          <tr class="group hover:bg-base-300">
            <td><%= client.type %></td>
            <td><%= client.name %></td>
            <td>
              <div class="dropdown">
                <div tabindex="0" role="button" class="btn btn-ghost btn-xs">
                  <span class="w-4"><%= length(client.sources) %></span>
                  <span class="hero-list-bullet h-5 w-5" />
                </div>
                <div
                  tabindex="0"
                  class="dropdown-content menu bg-base-100 rounded-box z-[1] w-52 p-4 shadow flex flex-col gap-2"
                >
                  <%= for source <- @sources do %>
                    <div class="flex flex-row items-center gap-2">
                      <input
                        type="checkbox"
                        phx-click="toggle_source"
                        phx-value-source_id={source.id}
                        phx-value-client_id={client.id}
                        checked={Enum.any?(client.sources, &(&1.id == source.id))}
                        class="checkbox checkbox-xs"
                      />
                      <.link class="hover:underline" navigate={~p"/source/#{source.id}"}>
                        <%= source.name %>
                      </.link>
                    </div>
                  <% end %>
                </div>
              </div>
            </td>
            <td>
              <.local_time date={client.created_at} id={"#{client.id}-created-at"} />
            </td>
            <td class="relative">
              <button
                phx-click="click_client"
                phx-value-id={client.id}
                class={[
                  "btn btn-xs btn-ghost",
                  "hidden group-hover:block",
                  "absolute right-4 bottom-3"
                ]}
              >
                <span class="hero-chevron-right h-4 w-4" />
              </button>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(_params, _session, socket) do
    %{accounts: [account]} = socket.assigns.current_user |> Ash.load!(:accounts)
    clients = Canary.Clients.Client |> Ash.read!()
    sources = Canary.Sources.Source |> Ash.read!()

    socket =
      socket
      |> assign(clients: clients)
      |> assign(sources: sources)
      |> assign(current_account: account)

    {:ok, socket}
  end

  def handle_event(
        "save",
        %{
          "type" => "Discord",
          "name" => name,
          "server_id" => server_id,
          "channel_id" => channel_id
        },
        socket
      ) do
    args = %{
      account: socket.assigns.current_account,
      name: name,
      discord_server_id: server_id,
      discord_channel_id: channel_id
    }

    client =
      Canary.Clients.Client
      |> Ash.Changeset.for_create(:create_discord, args)
      |> Ash.create!()

    clients = [client | socket.assigns.clients] |> Enum.sort_by(& &1.created_at)
    {:noreply, socket |> assign(clients: clients)}
  end

  def handle_event(
        "toggle_source",
        %{"source_id" => source_id, "client_id" => client_id} = args,
        socket
      ) do
    client = socket.assigns.clients |> Enum.find(&(&1.id == client_id))

    if args["value"] == "on" do
      client
      |> Ash.Changeset.for_update(:add_sources, %{sources: [%{id: source_id}]})
      |> Ash.update!()
    else
      client
      |> Ash.Changeset.for_update(:remove_sources, %{sources: [%{id: source_id}]})
      |> Ash.update!()
    end

    clients = socket.assigns.clients |> Ash.load!(:sources)
    {:noreply, socket |> assign(clients: clients)}
  end

  def handle_event("click_client", %{"id" => id}, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/client/#{id}")}
  end
end

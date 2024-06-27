defmodule CanaryWeb.SourcesLive do
  use CanaryWeb, :live_view
  import CanaryWeb.Layouts, only: [content_header: 1]

  def render(assigns) do
    ~H"""
    <.content_header>
      <div class="breadcrumbs text-md flex flex-row items-center justify-between">
        <ul>
          <li><a>Sources</a></li>
        </ul>
      </div>

      <button class="btn btn-sm btn-neutral ml-auto" onclick="modal.showModal()">
        Add new source
      </button>
    </.content_header>

    <dialog id="modal" class="modal">
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>

      <div class="modal-box flex flex-col">
        <form phx-submit="save" class="flex flex-col gap-2">
          <select name="type" class="select select-bordered w-full">
            <option selected>Web</option>
          </select>

          <label class="input input-bordered flex items-center gap-4">
            <span class="text-sm">Name</span>
            <input type="text" autocomplete="off" name="name" placeholder="e.g. docs" class="grow" />
          </label>

          <label class="input input-bordered flex items-center gap-4">
            <span class="text-sm">URL</span>
            <input
              type="url"
              autocomplete="off"
              name="url"
              placeholder="e.g. https://docs.example.com"
              class="grow"
            />
          </label>

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
          <th>Value</th>
          <th>Created at</th>
          <th>Updated at</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for source <- @sources do %>
          <tr class="group hover:bg-base-300">
            <td><%= source.type %></td>
            <td><%= source.name %></td>
            <td><%= source.web_base_url %></td>
            <td>
              <.local_time date={source.created_at} id={"#{source.id}-created-at"} />
            </td>
            <td>
              <.local_time
                :if={source.updated_at}
                date={source.updated_at}
                id={"#{source.id}-updated-at" }
              />
            </td>
            <td class="relative">
              <button
                phx-click="click_source"
                phx-value-id={source.id}
                class={[
                  "btn btn-xs btn-ghost",
                  "hidden group-hover:block",
                  "absolute right-4 bottom-2"
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
    sources = Canary.Sources.Source |> Ash.read!()

    socket =
      socket
      |> assign(sources: sources)
      |> assign(current_account: account)

    {:ok, socket}
  end

  def handle_event("save", %{"type" => "Web", "name" => name, "url" => url}, socket) do
    args = %{account: socket.assigns.current_account, name: name, web_base_url: url}

    source =
      Canary.Sources.Source
      |> Ash.Changeset.for_create(:create_web, args)
      |> Ash.create!()

    sources = [source | socket.assigns.sources] |> Enum.sort_by(& &1.created_at)
    {:noreply, socket |> assign(sources: sources)}
  end

  def handle_event("click_source", %{"id" => id}, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/source/#{id}")}
  end
end

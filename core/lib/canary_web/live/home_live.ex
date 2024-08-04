defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view
  import Ecto.Query

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <section class="stats stats-vertical w-full shadow-sm xl:stats-horizontal">
        <div class="stat">
          <div class="stat-title">Source</div>
          <div class="stat-value">
            <a href={@web_source.web_base_url} target="_blank" class="link link-hover">
              <%= URI.parse(@web_source.web_base_url).host %>
            </a>
          </div>
        </div>
        <div class="stat">
          <div class="stat-title">Documents</div>
          <div class="stat-value"><%= @web_source.num_documents %></div>
        </div>
        <div class="stat">
          <div class="stat-title">Status</div>
          <div class="stat-value">
            <%= if is_nil(@job) do %>
              Idle
            <% else %>
              <%= @job.state %>
            <% end %>
          </div>
        </div>
        <div class="stat">
          <div class="stat-title flex flex-row items-center gap-2">
            <span>Updated</span>
            <span
              phx-click="fetch"
              class="hero-arrow-path-solid h-4 w-4 text-neutural cursor-pointer"
            />
          </div>
          <%= if @web_source.last_updated  do %>
            <div id="updated" class="stat-value invisible" phx-hook="TimeAgo">
              <%= @web_source.last_updated %>
            </div>
          <% else %>
            <div class="stat-value">
              Never
            </div>
          <% end %>
        </div>
        <div></div>
      </section>

      <label class="form-control w-full max-w-xs mt-4">
        <div class="label">
          <span class="label-text">This is your public key.</span>
          <button
            id="pk"
            phx-hook="Clipboard"
            class="btn btn-sm btn-ghost"
            data-clipboard-text={@web_client.web_public_key}
          >
            Click here to copy
          </button>
        </div>
        <input
          type="text"
          value={@web_client.web_public_key}
          disabled
          class="input input-bordered w-full max-w-xs "
        />
        <div class="label"></div>
      </label>

      <span class="text-sm mb-2">Try it out!</span>
      <canary-root>
        <canary-provider-cloud key={@web_client.web_public_key} endpoint={CanaryWeb.Endpoint.url()}>
          <canary-modal>
            <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
            <canary-content slot="content">
              <canary-search slot="mode">
                <canary-search-input slot="input"></canary-search-input>
                <canary-search-results slot="result"></canary-search-results>
              </canary-search>
            </canary-content>
          </canary-modal>
        </canary-provider-cloud>
      </canary-root>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:sources, :clients])
    source = account.sources |> Enum.find(&(&1.type == :web))
    client = account.clients |> Enum.find(&(&1.type == :web))

    query =
      from j in Oban.Job,
        where: j.worker == "Canary.Workers.Fetcher",
        where: j.args["source_id"] == ^source.id,
        order_by: [desc: j.inserted_at],
        limit: 1

    socket =
      socket
      |> assign(current_account: account)
      |> assign(web_source: source)
      |> assign(web_client: client)
      |> assign(job: Canary.Repo.all(query) |> Enum.at(0))

    {:ok, socket}
  end

  def handle_event("fetch", _, socket) do
    source = socket.assigns.web_source

    case Canary.Workers.Fetcher.new(%{source_id: source.id}) |> Oban.insert() do
      {:ok, job} -> {:noreply, socket |> assign(job: job)}
      {:error, _} -> {:noreply, socket}
    end
  end
end

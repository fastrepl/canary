defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view
  import Ecto.Query

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <section class="stats stats-vertical w-full shadow-sm xl:stats-horizontal">
        <div class="stat">
          <div class="stat-title">Primary Source</div>
          <div class="stat-value"><%= URI.parse(@web_source.web_base_url).host %></div>
        </div>
        <div class="stat">
          <div class="stat-title">Indexed Documents</div>
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
            <span>Last Updated</span>
            <span
              phx-click="fetch"
              class="hero-arrow-path-solid h-4 w-4 text-neutural cursor-pointer"
            />
          </div>
          <%= if @web_source.last_updated  do %>
            <div id="updated" class="stat-value" phx-hook="TimeAgo">
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

      <section class="shadow-md mt-10 rounded-xl">
        <canary-panel key={@web_client.web_public_key} endpoint={CanaryWeb.Endpoint.url()}>
        </canary-panel>
      </section>

      <style>
        :root {
          --canary-color-accent-low: #ead3b9;
          --canary-color-accent: #955e00;
          --canary-color-accent-high: #482b00;
          --canary-color-white: #1d1711;
          --canary-color-gray-1: #302416;
          --canary-color-gray-2: #423627;
          --canary-color-gray-3: #635546;
          --canary-color-gray-4: #988978;
          --canary-color-gray-5: #c8c1b8;
          --canary-color-gray-6: #f3ece5;
          --canary-color-gray-7: #f9f6f2;
          --canary-color-black: #ffffff;
        }
      </style>
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
      |> assign(:job, Canary.Repo.all(query) |> Enum.at(0))

    IO.inspect(socket.assigns.job)
    {:ok, socket}
  end

  def handle_event("fetch", _, socket) do
    source = socket.assigns.web_source
    Canary.Workers.Fetcher.new(%{source_id: source.id}) |> Oban.insert()

    {:noreply, socket}
  end
end

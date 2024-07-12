defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view
  import Ecto.Query

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <section class="stats flex flex-row items-center">
        <div class="stat">
          <div class="stat-title">Primary Source</div>
          <div class="stat-value"><%= URI.parse(@primary_source.web_base_url).host %></div>
        </div>
        <div class="stat">
          <div class="stat-title">Indexed Documents</div>
          <div class="stat-value"><%= @primary_source.num_documents %></div>
        </div>
        <div class="stat">
          <div class="stat-title">Status</div>
          <div class="stat-value">Indexing</div>
        </div>
        <div class="stat">
          <div class="stat-title flex flex-row items-center gap-2">
            <span>Last Updated</span>
            <span
              phx-click="fetch"
              class="hero-arrow-path-solid h-4 w-4 text-neutural cursor-pointer"
            />
          </div>
          <div id="updated" class="stat-value" phx-hook="TimeAgo">
            <%= @primary_source.last_updated %>
          </div>
        </div>
        <div></div>
      </section>

      <section class="shadow-md mt-10 rounded-xl">
        <canary-panel endpoint="/"></canary-panel>
      </section>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:sources, :clients])
    source = account.sources |> Enum.find(&(&1.type == :web))

    socket = socket |> assign(primary_source: source)

    fetcher_query =
      from j in Oban.Job,
        where: j.worker == "Canary.Workers.Fetcher",
        where: j.args["source_id"] == ^source.id

    ingester_query =
      from j in Oban.Job,
        where: j.worker == "Canary.Workers.Ingester"

    {:ok, socket |> assign(current_account: account)}
  end

  def handle_event("fetch", _, socket) do
    [source] = socket.assigns.current_account.sources

    r = Canary.Workers.Fetcher.new(%{source_id: source.id}) |> Oban.insert()
    IO.inspect(r)

    {:noreply, socket}
  end
end

defmodule CanaryWeb.SourceLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div role="tablist" class="flex tabs tabs-lifted">
        <.tab name="Status" current={@mode} />
        <.tab name="Setting" current={@mode} />
      </div>

      <%= case @mode do %>
        <% "Status" -> %>
          <.status source={@source} fetcher_status={@fetcher_status} />
        <% "Setting" -> %>
          <.live_component id="crawler" module={CanaryWeb.SourceLive.Crawler} source={@source} />
      <% end %>
    </div>
    """
  end

  attr :name, :string
  attr :current, :string

  defp tab(assigns) do
    ~H"""
    <a
      role="tab"
      phx-click="set_mode"
      phx-value-mode={@name}
      class={["tab font-semibold", @current == @name && "tab-active"]}
    >
      <%= @name %>
    </a>
    """
  end

  defp status(assigns) do
    ~H"""
    <div>
      <section class="stats stats-vertical col-span-12 w-fullshadow-sm xl:stats-horizontal">
        <div class="stat">
          <div class="stat-title">Documents</div>
          <div class="stat-value"><%= @source.num_documents %></div>
        </div>

        <div class="stat">
          <div class="stat-title">Status</div>
          <div class="stat-value"><%= @fetcher_status %></div>
        </div>

        <div class="stat">
          <div class="stat-title flex flex-row items-center gap-2">
            <span>Updated</span>
            <span
              phx-click="fetch"
              class="hero-arrow-path-solid h-4 w-4 text-neutural cursor-pointer"
            />
          </div>
          <%= if @source.last_updated  do %>
            <div id="updated" class="stat-value invisible" phx-hook="TimeAgo">
              <%= @source.last_updated %>
            </div>
          <% else %>
            <div class="stat-value">
              Never
            </div>
          <% end %>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:sources])
    source = account.sources |> Enum.at(0)

    socket =
      socket
      |> assign(:mode, "Status")
      |> assign(source: source)
      |> assign(:fetcher_status, "IDLE")

    {:ok, socket}
  end

  @impl true
  def handle_event("set_mode", %{"mode" => mode}, socket) do
    {:noreply, socket |> assign(:mode, mode)}
  end

  @impl true
  def handle_event("fetch", _params, socket) do
    %{source_id: socket.assigns.source.id}
    |> Canary.Workers.Fetcher.new()
    |> Oban.insert()

    {:noreply, socket}

    # if DateTime.diff(DateTime.utc_now(), socket.assigns.source.last_updated, :hour) < 12 do
    #   {:noreply, socket}
    # else
    #   %{source_id: socket.assigns.source.id}
    #   |> Canary.Workers.Fetcher.new()
    #   |> Oban.insert()

    #   {:noreply, socket}
    # end
  end
end

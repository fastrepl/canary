defmodule CanaryWeb.SourceLive.Detail do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @crawler_preview_id "webpage-crawler-preview"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row justify-between items-center mb-4">
        <.back navigate={~p"/source"}>Back to list</.back>
        <div class="flex flex-row gap-2">
          <.button type="button" phx-click="destroy" phx-target={@myself} is_danger>
            Delete
          </.button>
          <.button type="submit" form="form" phx-target={@myself} is_primary>
            Save
          </.button>
        </div>
      </div>

      <div class="flex flex-col md:flex-row gap-12">
        <div class="basis-2/5">
          <%= case @source.config.type do %>
            <% :webpage -> %>
              <.live_component
                id="source-form"
                module={CanaryWeb.SourceLive.WebpageForm}
                source={@source}
              />
            <% :github_issue -> %>
              <.live_component
                id="source-form"
                module={CanaryWeb.SourceLive.GithubForm}
                source={@source}
              />
            <% :github_discussion -> %>
              <.live_component
                id="source-form"
                module={CanaryWeb.SourceLive.GithubForm}
                source={@source}
              />
          <% end %>
        </div>

        <div class="hidden md:inline-block min-h-[1em] w-0.5 self-stretch bg-gray-200"></div>

        <div class="basis-3/5">
          <Primer.tabnav aria_label="Tabs">
            <:item
              :for={tab <- @tabs}
              is_selected={tab == @tab}
              phx-click="set-tab"
              phx-target={@myself}
              phx-value-item={tab}
            >
              <%= tab %>
            </:item>
          </Primer.tabnav>

          <%= cond do %>
            <% @tab == Enum.at(@tabs, 0) -> %>
              <.status
                myself={@myself}
                source={@source}
                action_msg={@action_msg}
                action_name={@action_name}
              />
            <% @tab == Enum.at(@tabs, 1) -> %>
              <%= if @source.config.type == :webpage do %>
                <.live_component
                  id="webpage-crawler-preview"
                  module={CanaryWeb.SourceLive.WebpageCrawlerPreview}
                  config={@current_config}
                />
              <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :source, :any, default: nil
  attr :myself, :any, default: nil
  attr :action_msg, :string, default: "Fetch"
  attr :action_name, :string, default: "fetch"

  def status(assigns) do
    ~H"""
    <div>
      <Primer.timeline_item>
        <:badge><Primer.octicon name="check-16" /></:badge>
        <div class="flex flex-row items-center gap-2">
          <span class="font-semibold">
            <%= @source.num_documents %>
          </span>
          <span>
            documents indexed
          </span>
          <Primer.button phx-click={@action_name} phx-target={@myself} is_small>
            <%= @action_msg %>
          </Primer.button>
          <PrimerLive.Component.label
            is_accent={@source.state == :running}
            is_attention={@source.state == :error}
          >
            <%= String.upcase(to_string(@source.state)) %>
          </PrimerLive.Component.label>
        </div>
      </Primer.timeline_item>

      <div class="px-14 mb-3">
        <Primer.timeline_item is_break />
      </div>

      <%= for event <- @source.events do %>
        <Primer.timeline_item is_condensed>
          <:badge><Primer.octicon name="git-commit-16" /></:badge>
          <div class="flex flex-row justify-between">
            <span><%= event.meta.message %></span>
            <span id={"event-#{event.id}"} phx-hook="TimeAgo" class="invisible">
              <%= event.created_at %>
            </span>
          </div>
        </Primer.timeline_item>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    source = socket.assigns.source

    socket =
      socket
      |> assign_new(:current_config, fn ->
        %Ash.Union{value: config} = source.config

        Map.from_struct(config)
        |> Map.new(fn {k, v} -> {to_string(k), v} end)
      end)
      |> assign(source: source)
      |> assign(
        tabs: if(source.config.type == :webpage, do: ["Status", "Preview"], else: ["Status"])
      )
      |> assign(:tab, "Status")
      |> assign(action_msg: if(source.state == :running, do: "Cancel", else: "Fetch"))
      |> assign(action_name: if(source.state == :running, do: "cancel", else: "fetch"))
      |> assign(crawler_preview_id: @crawler_preview_id)

    {:ok, socket}
  end

  @impl true
  def handle_event("set-tab", %{"item" => tab}, socket) do
    if socket.assigns.tab == "Preview" do
      CanaryWeb.SourceLive.WebpageCrawlerPreview
      |> send_update(id: @crawler_preview_id, action: :cancel)
    end

    {:noreply, socket |> assign(:tab, tab)}
  end

  def handle_event("destroy", _, socket) do
    case Ash.destroy(socket.assigns.source) do
      :ok ->
        socket =
          socket
          |> put_flash(:info, "Source has been deleted!")
          |> push_navigate(to: ~p"/source")

        {:noreply, socket}

      error ->
        socket =
          socket
          |> put_flash(:error, error)
          |> push_navigate(to: ~p"/source")

        {:noreply, socket}
    end
  end

  def handle_event("fetch", _, socket) do
    result =
      socket.assigns.source
      |> Ash.Changeset.for_update(:fetch, %{})
      |> Ash.update()

    case result do
      {:ok, _} ->
        {:noreply, socket}

      {:error, error} ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end

  def handle_event("cancel", _, socket) do
    result =
      socket.assigns.source
      |> Ash.Changeset.for_update(:cancel_fetch, %{})
      |> Ash.update()

    case result do
      {:ok, _} ->
        {:noreply, socket}

      {:error, error} ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end
end

defmodule CanaryWeb.SourceLive.Detail do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row justify-between items-center mb-4">
        <Primer.breadcrumb>
          <:item navigate={~p"/source"}>Source</:item>
          <:item>Detail</:item>
        </Primer.breadcrumb>

        <div class="flex flex-row gap-2">
          <Primer.button type="button" phx-click="destroy" phx-target={@myself} is_danger>
            Delete
          </Primer.button>
          <Primer.button type="submit" form="form" phx-target={@myself} is_primary>
            Save
          </Primer.button>
        </div>
      </div>

      <div class="flex flex-col md:flex-row justify-between gap-12">
        <.form
          :let={f}
          id="form"
          for={@form}
          phx-submit="submit"
          phx-change="validate"
          phx-target={@myself}
          class="flex flex-col gap-6 basis-2/5"
        >
          <Primer.text_input
            value={@source.config.type}
            disabled
            is_large
            is_full_width
            form_control={%{label: "Type"}}
          />

          <Primer.text_input
            form={f}
            field={:name}
            is_large
            is_full_width
            form_control={%{label: "Name"}}
          />

          <.inputs_for :let={fc} field={@form[:config]}>
            <%= case @source.config.type do %>
              <% :webpage -> %>
                <Primer.form_control label="URLs">
                  <%= for url <- fc[:start_urls].value || [] do %>
                    <div class="flex flex-row w-full items-center gap-2">
                      <Primer.text_input
                        type="url"
                        name={fc[:start_urls].name <> "[]"}
                        value={url}
                        is_full_width
                        is_large
                      />
                      <%!-- <Primer.button
                        type="button"
                        phx-click="start_urls-remove"
                        phx-target={@myself}
                        is_icon_button
                        is_small
                      >
                        <Primer.octicon name="x-16" />
                      </Primer.button> --%>
                    </div>
                  <% end %>
                  <%!-- <div class="h-2"></div>
                  <Primer.button
                    type="button"
                    phx-click="start_urls-add"
                    phx-target={@myself}
                    is_small
                    is_full_width
                  >
                    <Primer.octicon name="plus-16" />
                  </Primer.button> --%>
                </Primer.form_control>

                <Primer.form_control label="Include patterns">
                  <%= for url <- fc[:url_include_patterns].value || [] do %>
                    <Primer.text_input
                      type="text"
                      name={fc[:url_include_patterns].name <> "[]"}
                      value={url}
                      is_full_width
                      is_large
                      caption={
                        fn _state ->
                          ~H'''
                          Comma separated list of glob patterns.
                          '''
                        end
                      }
                    />
                  <% end %>
                </Primer.form_control>

                <Primer.form_control label="Exclude patterns">
                  <%= for url <- fc[:url_exclude_patterns].value || [] do %>
                    <Primer.text_input
                      type="text"
                      name={fc[:url_exclude_patterns].name <> "[]"}
                      value={url}
                      is_full_width
                      is_large
                      caption={
                        fn _state ->
                          ~H'''
                          Comma separated list of glob patterns.
                          '''
                        end
                      }
                    />
                  <% end %>
                </Primer.form_control>
              <% :github_issue -> %>
                <Primer.text_input
                  form={fc}
                  field={:owner}
                  is_large
                  is_full_width
                  form_control={%{label: "Owner"}}
                />
                <Primer.text_input
                  form={fc}
                  field={:repo}
                  is_large
                  is_full_width
                  form_control={%{label: "Repo"}}
                />
              <% :github_discussion -> %>
                <Primer.text_input
                  form={fc}
                  field={:owner}
                  is_large
                  is_full_width
                  form_control={%{label: "Owner"}}
                />
                <Primer.text_input
                  form={fc}
                  field={:repo}
                  is_large
                  is_full_width
                  form_control={%{label: "Repo"}}
                />
            <% end %>
          </.inputs_for>
        </.form>

        <div class="hidden md:inline-block min-h-[1em] w-0.5 self-stretch bg-gray-200"></div>

        <div class="basis-3/5">
          <Primer.tabnav aria_label="Tabs">
            <:item
              is_selected={Enum.at(@tabs, 0) == @tab}
              phx-click="set-tab"
              phx-target={@myself}
              phx-value-tab={Enum.at(@tabs, 0)}
            >
              <%= Enum.at(@tabs, 0) %>
            </:item>
            <:item
              is_selected={Enum.at(@tabs, 1) == @tab}
              phx-click="set-tab"
              phx-target={@myself}
              phx-value-tab={Enum.at(@tabs, 1)}
            >
              <%= Enum.at(@tabs, 1) %>
            </:item>
          </Primer.tabnav>

          <%= cond do %>
            <% @tab == Enum.at(@tabs, 0) -> %>
              <.status myself={@myself} source={@source} />
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
          <Primer.button phx-click="fetch" phx-target={@myself} is_small>
            Refresh
          </Primer.button>
        </div>
      </Primer.timeline_item>

      <div class="px-14 mb-3">
        <Primer.timeline_item is_break />
      </div>

      <%= for event <- @source.events do %>
        <Primer.timeline_item is_condensed>
          <:badge><Primer.octicon name="git-commit-16" /></:badge>
          <span id={"event-#{event.id}"} phx-hook="TimeAgo" class="badge">
            <%= event.created_at %>
          </span>
        </Primer.timeline_item>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    form =
      socket.assigns.source
      |> AshPhoenix.Form.for_update(:update, forms: [auto?: true])
      |> to_form()

    socket =
      socket
      |> assign(form: form)
      |> assign(source: socket.assigns.source)
      |> assign(tabs: ["Status", "Documents"])
      |> assign(:tab, "Status")
      |> assign_new(:current_config, fn ->
        %Ash.Union{type: :webpage, value: config} = form.data.config

        Map.from_struct(config)
        |> Map.new(fn {k, v} -> {to_string(k), v} end)
      end)

    {:ok, socket}
  end

  @impl true
  def handle_event("set-tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    socket =
      socket
      |> assign(form: form)
      |> assign(current_config: form.params["config"])

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    IO.inspect(params)

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, form} = e ->
        IO.inspect(e)
        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event("start_urls-add", _, socket) do
    params =
      socket.assigns.form.params
      |> update_in(["config", "start_urls"], &((&1 || []) ++ [""]))

    form =
      socket.assigns.form
      |> AshPhoenix.Form.validate(params)

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("destroy", _, socket) do
    case Ash.destroy(socket.assigns.source) do
      :ok ->
        {:noreply, socket |> redirect(to: ~p"/source")}

      error ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("fetch", _, socket) do
    %Canary.Sources.Source{id: id, config: %Ash.Union{type: type}} = socket.assigns.source

    job =
      case type do
        :webpage -> Canary.Workers.WebpageFetcher.new(%{source_id: id})
        :github_issue -> Canary.Workers.GithubIssueFetcher.new(%{source_id: id})
        :github_discussion -> Canary.Workers.GithubDiscussionFetcher.new(%{source_id: id})
      end

    case Oban.insert(job) do
      {:ok, _} ->
        {:noreply, socket}

      error ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end
end

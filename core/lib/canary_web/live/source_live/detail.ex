defmodule CanaryWeb.SourceLive.Detail do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  require Ecto.Query

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
            value={
              case @source.config.type do
                :webpage -> "Webpage"
                :github_issue -> "Github Issue"
                :github_discussion -> "Github Discussion"
              end
            }
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
                      />
                      <%!-- <Primer.button
                        type="button"
                        phx-click={JS.dispatch("change")}
                        phx-target={@myself}
                        is_small
                        is_icon_button
                      >
                        <Primer.octicon name="x-16" />
                      </Primer.button> --%>
                    </div>
                  <% end %>
                  <div class="h-1"></div>
                  <Primer.button
                    type="button"
                    phx-click={JS.dispatch("change")}
                    name={fc[:start_urls].name <> "[]"}
                    phx-target={@myself}
                    is_small
                    is_full_width
                  >
                    <Primer.octicon name="plus-16" />
                  </Primer.button>
                </Primer.form_control>

                <Primer.form_control label="Include patterns">
                  <%= for url <- fc[:url_include_patterns].value || [] do %>
                    <Primer.text_input
                      type="text"
                      name={fc[:url_include_patterns].name <> "[]"}
                      value={url}
                      is_full_width
                    />
                  <% end %>

                  <div class="h-1"></div>
                  <Primer.button
                    type="button"
                    phx-click={JS.dispatch("change")}
                    name={fc[:url_include_patterns].name <> "[]"}
                    phx-target={@myself}
                    is_small
                    is_full_width
                  >
                    <Primer.octicon name="plus-16" />
                  </Primer.button>
                </Primer.form_control>

                <Primer.form_control label="Exclude patterns">
                  <%= for url <- fc[:url_exclude_patterns].value || [] do %>
                    <div class="flex flex-row w-full items-center gap-2">
                      <Primer.text_input
                        type="text"
                        name={fc[:url_exclude_patterns].name <> "[]"}
                        value={url}
                        is_full_width
                      />
                    </div>
                  <% end %>

                  <div class="h-1"></div>
                  <Primer.button
                    type="button"
                    phx-click={JS.dispatch("change")}
                    name={fc[:url_exclude_patterns].name <> "[]"}
                    phx-target={@myself}
                    is_small
                    is_full_width
                  >
                    <Primer.octicon name="plus-16" />
                  </Primer.button>
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
                  form_control={%{label: "Repository"}}
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
                  form_control={%{label: "Repository"}}
                />
            <% end %>
          </.inputs_for>
        </.form>

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
            <span id={"event-#{event.id}"} phx-hook="TimeAgo" class="badge">
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

    form =
      source
      |> AshPhoenix.Form.for_update(:update, forms: [auto?: true])
      |> to_form()

    socket =
      socket
      |> assign(form: form)
      |> assign(source: source)
      |> assign(
        tabs: if(source.config.type == :webpage, do: ["Status", "Preview"], else: ["Status"])
      )
      |> assign(:tab, "Status")
      |> assign_new(:current_config, fn ->
        %Ash.Union{value: config} = form.data.config

        Map.from_struct(config)
        |> Map.new(fn {k, v} -> {to_string(k), v} end)
      end)
      |> assign(action_msg: if(source.state == :running, do: "Cancel", else: "Fetch"))
      |> assign(action_name: if(source.state == :running, do: "cancel", else: "fetch"))

    {:ok, socket}
  end

  @impl true
  def handle_event("set-tab", %{"item" => tab}, socket) do
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
    params = transform_params(params)

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        {:noreply, socket |> push_navigate(to: ~p"/source/#{socket.assigns.source.id}")}

      {:error, form} = e ->
        IO.inspect(e)
        {:noreply, assign(socket, :form, form)}
    end
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

  @impl true
  def handle_event("cancel", _, socket) do
    worker =
      case socket.assigns.source.config.type do
        :webpage -> Canary.Workers.WebpageProcessor
        :github_issue -> Canary.Workers.GithubIssueProcessor
        :github_discussion -> Canary.Workers.GithubDiscussionProcessor
      end
      |> to_string()
      |> String.trim_leading("Elixir.")

    Oban.Job
    |> Ecto.Query.where(worker: ^worker)
    |> Oban.cancel_all_jobs()

    {:noreply, socket}
  end

  defp transform_params(params) do
    [
      "start_urls",
      "url_include_patterns",
      "url_exclude_patterns"
    ]
    |> Enum.reduce(params, fn key, acc ->
      if not is_list(acc["config"][key]) do
        acc
      else
        update_in(acc, ["config", key], fn list ->
          list
          |> Enum.map(&String.trim/1)
          |> Enum.reject(&(&1 == ""))
        end)
      end
    end)
  end
end

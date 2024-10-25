defmodule CanaryWeb.SourceLive.WebpageForm do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
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
          autocomplete="off"
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
          autocomplete="off"
          form={f}
          field={:name}
          is_large
          is_full_width
          form_control={%{label: "Name"}}
        />

        <.inputs_for :let={fc} field={@form[:config]}>
          <%= case @source.config.type do %>
            <% :webpage -> %>
              <.form_group header="URLs">
                <%= for url <- fc[:start_urls].value || [] do %>
                  <div class="flex flex-row w-full items-center gap-2">
                    <Primer.text_input
                      autocomplete="off"
                      type="url"
                      name={fc[:start_urls].name <> "[]"}
                      value={url}
                      is_full_width
                    />
                  </div>
                <% end %>
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
              </.form_group>

              <.form_group header="Include patterns">
                <%= for url <- fc[:url_include_patterns].value || [] do %>
                  <Primer.text_input
                    autocomplete="off"
                    type="text"
                    name={fc[:url_include_patterns].name <> "[]"}
                    value={url}
                    is_full_width
                  />
                <% end %>
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
              </.form_group>

              <.form_group header="Exclude patterns">
                <%= for url <- fc[:url_exclude_patterns].value || [] do %>
                  <div class="flex flex-row w-full items-center gap-2">
                    <Primer.text_input
                      autocomplete="off"
                      type="text"
                      name={fc[:url_exclude_patterns].name <> "[]"}
                      value={url}
                      is_full_width
                    />
                  </div>
                <% end %>

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
              </.form_group>

              <.form_group header="Tags">
                <div class="flex flex-col gap-6">
                  <%= for tag_def <- fc[:tag_definitions].value || [] do %>
                    <div class="flex flex-col w-full gap-2 pl-2">
                      <Primer.text_input
                        autocomplete="off"
                        type="text"
                        name={tag_def[:name].name}
                        value={tag_def[:name].value}
                        is_full_width
                        form_control={%{label: "Name"}}
                      />
                      <Primer.text_input
                        autocomplete="off"
                        type="text"
                        name={tag_def[:url_include_patterns].name <> "[]"}
                        value={tag_def[:url_include_patterns].value |> Enum.join(",")}
                        is_full_width
                        form_control={%{label: "Include patterns"}}
                      />
                    </div>
                  <% end %>
                </div>

                <Primer.button
                  type="button"
                  phx-click={JS.dispatch("change")}
                  name={fc[:tag_definitions].name <> "[#{Enum.count(fc[:tag_definitions].value || [])}]"}
                  phx-target={@myself}
                  is_small
                  is_full_width
                >
                  <Primer.octicon name="plus-16" />
                </Primer.button>
              </.form_group>

              <.form_group header="JS Render (experimental)">
                <.input type="checkbox" field={fc[:js_render]} />
              </.form_group>
            <% :github_issue -> %>
              <Primer.text_input
                autocomplete="off"
                form={fc}
                field={:owner}
                is_large
                is_full_width
                form_control={%{label: "Owner"}}
              />
              <Primer.text_input
                autocomplete="off"
                form={fc}
                field={:repo}
                is_large
                is_full_width
                form_control={%{label: "Repository"}}
              />
            <% :github_discussion -> %>
              <Primer.text_input
                autocomplete="off"
                form={fc}
                field={:owner}
                is_large
                is_full_width
                form_control={%{label: "Owner"}}
              />
              <Primer.text_input
                autocomplete="off"
                form={fc}
                field={:repo}
                is_large
                is_full_width
                form_control={%{label: "Repository"}}
              />
          <% end %>
        </.inputs_for>
      </.form>
    </div>
    """
  end

  attr :header, :string, required: true
  slot :inner_block, required: true

  def form_group(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <div class="form-group-header">
        <span class="FormControl-label"><%= @header %></span>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "Source has been updated!")
          |> push_navigate(to: ~p"/source/#{socket.assigns.source.id}")

        {:noreply, socket}

      {:error, form} = e ->
        IO.inspect(e)
        {:noreply, assign(socket, :form, form)}
    end
  end
end

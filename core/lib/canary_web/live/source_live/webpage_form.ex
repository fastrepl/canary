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
        class="flex flex-col gap-4"
      >
        <.input name="type" value="Webpage" label="Type" disabled />
        <.input field={f[:name]} label="Name" />

        <.inputs_for :let={fc} field={@form[:config]}>
          <.form_group header="URLs">
            <%= for url <- fc[:start_urls].value || [] do %>
              <.input type="url" autocomplete="off" name={fc[:start_urls].name <> "[]"} value={url} />
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
              <.input autocomplete="off" name={fc[:url_include_patterns].name <> "[]"} value={url} />
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
              <.input autocomplete="off" name={fc[:url_exclude_patterns].name <> "[]"} value={url} />
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
              <.inputs_for :let={fct} field={fc[:tag_definitions]}>
                <div class="flex flex-col gap-2">
                  <.form_group header="Name">
                    <:action>
                      <Primer.octicon
                        class="ml-auto text-gray-400 cursor-pointer"
                        name="x-16"
                        phx-target={@myself}
                        phx-click="remove_tag"
                        phx-value-item={fct.name}
                      />
                    </:action>
                    <.input autocomplete="off" field={fct[:name]} />
                  </.form_group>

                  <.form_group header="Include patterns">
                    <div class="flex flex-col gap-2 p-2 border rounded-md">
                      <%= for url <- fct[:url_include_patterns].value || [] do %>
                        <.input
                          autocomplete="off"
                          name={fct[:url_include_patterns].name <> "[]"}
                          value={url}
                        />
                      <% end %>
                      <Primer.button
                        type="button"
                        phx-click={JS.dispatch("change")}
                        name={fct[:url_include_patterns].name <> "[]"}
                        phx-target={@myself}
                        is_small
                        is_full_width
                      >
                        <Primer.octicon name="plus-16" />
                      </Primer.button>
                    </div>
                  </.form_group>
                </div>
              </.inputs_for>
            </div>

            <Primer.button
              type="button"
              phx-click="add_tag"
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
        </.inputs_for>
      </.form>
    </div>
    """
  end

  attr :header, :string, required: true
  slot :inner_block, required: true
  slot :action

  def form_group(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <div class="form-group-header flex items-center justify-between">
        <span class="FormControl-label"><%= @header %></span>
        <%= render_slot(@action) %>
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
      |> assign_form()

    {:ok, socket}
  end

  defp assign_form(socket) do
    form =
      socket.assigns.source
      |> AshPhoenix.Form.for_update(:update, forms: [auto?: true])
      |> to_form()

    socket |> assign(:form, form)
  end

  defp drop_empty(params) do
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

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    params = drop_empty(params)

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "Source has been updated!")
          |> push_navigate(to: ~p"/source/#{socket.assigns.source.id}")

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> assign(:form, form)
          |> put_flash(:error, "Failed to update source")

        {:noreply, socket}
    end
  end

  def handle_event("add_tag", _, socket) do
    form =
      socket.assigns.form
      |> AshPhoenix.Form.add_form(
        ["config", "tag_definitions"],
        params: %{"name" => "tag", "url_include_patterns" => %{"0" => "https://example.com/**"}}
      )

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("remove_tag", %{"item" => item}, socket) do
    form = socket.assigns.form |> AshPhoenix.Form.remove_form(item)
    {:noreply, assign(socket, form: form)}
  end
end

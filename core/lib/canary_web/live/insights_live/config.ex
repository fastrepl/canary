defmodule CanaryWeb.InsightLive.Config do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="text-md font-semibold">Aliases</div>
      <div class="mb-4">
        <div>Set this if you want to combine duplicated queries.</div>
        <div>
          Click
          <span
            class="hero-sparkles w-5 h-5 cursor-pointer"
            phx-click="generate"
            phx-target={@myself}
            phx-value-item={@form.name}
          >
          </span>
          to generate from scratch.
        </div>
        <div :if={@generating?}>Generating... (may takes ~10 seconds)</div>
      </div>

      <.form
        :let={f}
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="submit"
        class="flex flex-col gap-4"
      >
        <input type="hidden" name={f[:project_id].name} value={@current_project.id} />

        <.inputs_for :let={fc} field={f[:aliases]}>
          <div class="p-2 border-2 border-gray-200 rounded-md flex flex-col gap-4">
            <div class="flex flex-row justify-between">
              <Primer.text_input
                autocomplete="off"
                form={fc}
                field={:name}
                is_full_width
                form_control={%{label: "Name"}}
              />
              <Primer.octicon
                class="ml-auto"
                name="x-16"
                phx-target={@myself}
                phx-click="remove_alias"
                phx-value-item={fc.name}
              />
            </div>
            <.form_group header="Members">
              <%= for {member, index} <- Enum.with_index(fc[:members].value || []) do %>
                <div class="flex flex-row gap-2 items-center">
                  <Primer.text_input
                    autocomplete="off"
                    name={fc.name <> "[members][#{index}]"}
                    value={member}
                    is_full_width
                  />
                  <Primer.octicon
                    class="cursor-pointer"
                    name="x-16"
                    phx-target={@myself}
                    phx-click="remove_member"
                    phx-value-item={fc.name <> "[members][#{index}]"}
                  />
                </div>
              <% end %>
              <Primer.button
                type="button"
                phx-target={@myself}
                phx-click="add_member"
                phx-value-item={fc.name}
                is_small
              >
                +
              </Primer.button>
            </.form_group>
          </div>
        </.inputs_for>

        <Primer.button type="button" phx-target={@myself} phx-click="add_alias">
          +
        </Primer.button>

        <Primer.button type="submit" phx-target={@myself}>
          Save
        </Primer.button>
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
      |> assign_form()
      |> assign(:generating?, false)

    {:ok, socket}
  end

  defp assign_form(socket) do
    if socket.assigns.current_project.insights_config do
      socket |> assign_update_form()
    else
      socket |> assign_create_form()
    end
  end

  defp assign_create_form(socket) do
    form =
      Canary.Insights.Config
      |> AshPhoenix.Form.for_create(:create, forms: [auto?: true])
      |> to_form()

    socket |> assign(:form, form)
  end

  defp assign_update_form(socket) do
    form =
      socket.assigns.current_project.insights_config
      |> AshPhoenix.Form.for_update(:update, forms: [auto?: true])
      |> to_form()

    socket |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} -> {:noreply, socket |> push_navigate(to: ~p"/insight")}
      {:error, form} -> {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("add_alias", _, socket) do
    empty = %{"name" => "", "members" => %{}}

    form =
      socket.assigns.form
      |> AshPhoenix.Form.add_form("aliases", params: empty)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("remove_alias", %{"item" => item}, socket) do
    form = socket.assigns.form |> AshPhoenix.Form.remove_form(item)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("add_member", %{"item" => path}, socket) do
    form =
      socket.assigns.form
      |> AshPhoenix.Form.update_form(path, fn nested_form ->
        # TODO: not work with update
        params =
          nested_form.params
          |> Map.update("members", %{}, fn existing ->
            new_key = existing |> map_size() |> to_string()
            existing |> Map.put(new_key, "")
          end)

        AshPhoenix.Form.validate(nested_form, params)
      end)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("remove_member", %{"item" => item}, socket) do
    [path, nth] = String.split(item, "[members]")
    nth = nth |> String.at(1) |> String.to_integer()

    form =
      socket.assigns.form
      |> AshPhoenix.Form.update_form(path, fn nested_form ->
        params =
          nested_form.params
          |> Map.update("members", %{}, fn existing ->
            existing
            |> Enum.sort_by(fn {key, _} -> String.to_integer(key) end)
            |> List.delete_at(nth)
            |> Map.new()
          end)

        AshPhoenix.Form.validate(nested_form, params)
      end)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("generate", %{"item" => path}, socket) do
    quries = socket.assigns.quries |> Enum.slice(0, 20)

    socket =
      socket
      |> assign(:generating?, true)
      |> start_async(:generate, fn ->
        {:ok, completion} =
          Canary.AI.chat(%{
            model: Application.fetch_env!(:canary, :general_model),
            messages: [
              %{
                role: "user",
                content: """
                #{quries}
                ---

                Above are quries user typed in the search bar.
                Some of them are just partial queries performed while typing, and some of them are full queries but similar.
                Write down aliases if they can be combined. Take extra care on partial queries.

                For example, if we have "examp", "example" and "exam" in the quries list, we can combine them into:
                name: "example",
                members: ["example", "examp", "exam"]

                Each item in "members" must be picked from the above queries, without any extra text.
                """
              }
            ],
            temperature: 0,
            max_tokens: 2000,
            response_format: %{
              type: "json_schema",
              json_schema: %{
                name: "Aliases",
                strict: true,
                schema: %{
                  type: "object",
                  properties: %{
                    aliases: %{
                      type: "array",
                      items: %{
                        type: "object",
                        properties: %{
                          name: %{type: "string"},
                          members: %{
                            type: "array",
                            items: %{type: "string"}
                          }
                        },
                        required: ["name", "members"],
                        additionalProperties: false
                      }
                    }
                  },
                  required: ["aliases"],
                  additionalProperties: false
                }
              }
            }
          })

        {path, Jason.decode!(completion)}
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_async(:generate, {:ok, {path, data}}, socket) do
    form =
      socket.assigns.form
      |> AshPhoenix.Form.update_form(path, fn nested_form ->
        params = Map.merge(nested_form.params, data)
        AshPhoenix.Form.validate(nested_form, params)
      end)

    socket =
      socket
      |> assign(:generating?, false)
      |> assign(:form, form)

    {:noreply, socket}
  end
end

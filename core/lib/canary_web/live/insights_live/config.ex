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
                class="ml-auto cursor-pointer"
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
        params =
          nested_form
          |> then(fn form ->
            params = AshPhoenix.Form.params(nested_form)

            cond do
              is_nil(form.data) ->
                params

              map_size(params) == 0 ->
                %{
                  "name" => nested_form.data.name,
                  "members" =>
                    nested_form.data.members
                    |> Enum.with_index()
                    |> Map.new(fn {v, i} -> {"#{i}", v} end)
                }

              true ->
                Map.merge(
                  %{
                    "name" => nested_form.data.name,
                    "members" =>
                      nested_form.data.members
                      |> Enum.with_index()
                      |> Map.new(fn {v, i} -> {"#{i}", v} end)
                  },
                  params
                )
            end
          end)
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
          nested_form
          |> then(fn form ->
            params = AshPhoenix.Form.params(nested_form)

            cond do
              is_nil(form.data) ->
                params

              map_size(params) == 0 ->
                %{
                  "name" => nested_form.data.name,
                  "members" =>
                    nested_form.data.members
                    |> Enum.with_index()
                    |> Map.new(fn {v, i} -> {"#{i}", v} end)
                }

              true ->
                Map.merge(
                  %{
                    "name" => nested_form.data.name,
                    "members" =>
                      nested_form.data.members
                      |> Enum.with_index()
                      |> Map.new(fn {v, i} -> {"#{i}", v} end)
                  },
                  params
                )
            end
          end)
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
end

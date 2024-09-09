defmodule CanaryWeb.SettingsLive.KeyForm do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @config_types [
    {"Public", "public"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>Key</Primer.subhead>

      <div class="flex flex-col gap-4">
        <ul class="flex flex-col gap-2">
          <%= for %{id: id, value: value} <- @current_account.keys do %>
            <li class="flex flex-row items-center gap-2">
              <Primer.text_input disabled value={value}>
                <:group_button>
                  <Primer.button
                    aria-label="Copy"
                    id={"key-#{id}"}
                    phx-hook="Clipboard"
                    data-clipboard-text={value}
                  >
                    <Primer.octicon name="paste-16" />
                  </Primer.button>
                </:group_button>
              </Primer.text_input>

              <Primer.button
                phx-click="destroy"
                phx-target={@myself}
                phx-value-id={id}
                is_small
                is_close_button
              >
                <Primer.octicon name="x-16" />
              </Primer.button>
            </li>
          <% end %>
        </ul>

        <div class="flex justify-end">
          <Primer.button is_primary onclick="Prompt.show('#key-form')">
            Create
          </Primer.button>
        </div>
      </div>

      <Primer.dialog id="key-form" is_backdrop>
        <:header_title>Create a new key</:header_title>
        <:body>
          <.form
            :let={f}
            for={@form}
            phx-submit="submit"
            phx-target={@myself}
            class="flex flex-col gap-2"
          >
            <input type="hidden" name={f[:account_id].name} value={@current_account.id} />

            <.inputs_for :let={fc} field={@form[:config]}>
              <Primer.select
                is_full_width
                phx-change="type-changed"
                form={fc}
                field={:_union_type}
                options={@config_types}
              />

              <%= case fc.params["_union_type"] do %>
                <% "public" -> %>
                  <Primer.text_input
                    is_full_width
                    form={fc}
                    field={:allowed_host}
                    placeholder="Allowed host"
                  />
              <% end %>
            </.inputs_for>

            <button type="submit" class="btn btn-neutral btn-sm">
              Create
            </button>
          </.form>
        </:body>
      </Primer.dialog>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:config_types, @config_types)

    form =
      Canary.Accounts.Key
      |> AshPhoenix.Form.for_create(:create, forms: [auto?: true])
      |> then(fn form ->
        if form.forms[:config] do
          form
        else
          type = @config_types |> Enum.at(0) |> elem(1)
          AshPhoenix.Form.add_form(form, [:config], params: %{"_union_type" => type})
        end
      end)
      |> to_form()

    {:ok, socket |> assign(:form, form)}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _record} ->
        {:noreply, socket |> redirect(to: ~p"/settings")}

      {:error, updated_form} = e ->
        IO.inspect(e)
        {:noreply, assign(socket, :form, updated_form)}
    end
  end

  @impl true
  def handle_event("destroy", %{"id" => id}, socket) do
    key =
      socket.assigns.current_account.keys
      |> Enum.find(fn key -> key.id == id end)

    case Ash.destroy(key) do
      :ok ->
        {:noreply, socket |> redirect(to: ~p"/settings")}

      error ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end
end

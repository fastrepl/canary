defmodule CanaryWeb.SettingsLive.CreateProject do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
        class="flex flex-col gap-4"
      >
        <input type="hidden" name={f[:account_id].name} value={@current_account.id} />

        <Primer.text_input
          autocomplete="off"
          type="text"
          form={f}
          field={:name}
          form_control={%{label: "Name"}}
          is_large
          is_full_width
        />

        <div class="flex flex-row gap-2 justify-end">
          <Primer.button type="submit" is_primary>
            Create
          </Primer.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = socket |> assign(assigns)

    form =
      Canary.Accounts.Project
      |> AshPhoenix.Form.for_create(:create, forms: [auto?: true])
      |> to_form()

    {:ok, socket |> assign(:form, form)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} -> {:noreply, socket |> push_navigate(to: ~p"/settings/projects")}
      {:error, form} -> {:noreply, assign(socket, :form, form)}
    end
  end
end

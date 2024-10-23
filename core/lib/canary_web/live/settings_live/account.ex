defmodule CanaryWeb.SettingsLive.Account do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="flex flex-col gap-8"
      >
        <input type="hidden" name={@form[:user_id].name} value={@current_user.id} />
        <.input field={@form[:name]} label="Name" />

        <div class="flex flex-row gap-2 justify-end">
          <.button type="button" phx-target={@myself} phx-click="destroy" is_danger>
            Delete
          </.button>
          <.button type="submit" is_primary>
            Update
          </.button>
        </div>
      </.form>
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
      socket.assigns.current_account
      |> AshPhoenix.Form.for_update(:update)
      |> to_form()

    socket |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} -> {:noreply, socket |> push_navigate(to: ~p"/settings")}
      {:error, form} -> {:noreply, socket |> assign(:form, form)}
    end
  end

  def handle_event("destroy", _, socket) do
    socket =
      socket
      |> put_flash(:error, "Please contact us if you want to delete your project.")
      |> push_navigate(to: ~p"/settings")

    {:noreply, socket}
  end
end

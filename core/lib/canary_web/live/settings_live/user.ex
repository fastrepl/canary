defmodule CanaryWeb.SettingsLive.User do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-submit="submit" class="flex flex-col gap-4">
        <.input type="email" autocomplete="off" field={f[:email]} label="Email" />
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
      socket.assigns.current_user
      |> AshPhoenix.Form.for_update(:update)
      |> to_form()

    socket |> assign(:form, form)
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _record} ->
        {:noreply, assign_form(socket)}

      {:error, updated_form} = e ->
        IO.inspect(e)
        {:noreply, assign(socket, :form, updated_form)}
    end

    {:noreply, socket}
  end

  def handle_event("destroy", _, socket) do
    socket =
      socket
      |> put_flash(:error, "Please contact us if you want to delete your project.")
      |> push_navigate(to: ~p"/settings")

    {:noreply, socket}
  end
end

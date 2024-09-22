defmodule CanaryWeb.SettingsLive.UserForm do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-submit="submit" phx-target={@myself} class="flex flex-col gap-4">
        <Primer.text_input
          form={f}
          field={:email}
          type="email"
          form_control={%{label: "Email"}}
          is_large
          is_full_width
        />

        <div class="flex flex-row gap-2 justify-end">
          <Primer.button type="button" phx-click="destroy" phx-target={@myself} is_danger>
            Delete
          </Primer.button>
          <Primer.button type="submit" is_primary>
            Update
          </Primer.button>
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

  @impl true
  def handle_event("destroy", _, socket) do
    case Ash.destroy(socket.assigns.current_user) do
      :ok ->
        {:noreply, socket |> redirect(to: ~p"/")}

      {:error, e} ->
        IO.inspect(e)

        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete account")
         |> push_navigate(to: ~p"/settings")}
    end
  end
end

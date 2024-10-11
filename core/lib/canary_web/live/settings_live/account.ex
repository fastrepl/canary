defmodule CanaryWeb.SettingsLive.Account do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>Account</Primer.subhead>

      <.form :let={f} for={@form} phx-submit="submit" class="flex flex-col gap-4">
        <Primer.text_input
          type="email"
          form={f}
          field={:email}
          form_control={%{label: "Email"}}
          is_large
          is_full_width
          caption={
            fn ->
              cond do
                Application.get_env(:canary, :self_host) -> ""
                is_nil(@current_user.confirmed_at) -> "Email NOT confirmed"
                true -> "Email confirmed"
              end
            end
          }
        />
        <div class="flex flex-row gap-2 justify-end">
          <Primer.button type="button" phx-click="destroy" is_danger>
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
  def mount(_params, _session, socket) do
    socket = socket |> assign_form()
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
    case Ash.destroy(socket.assigns.current_account) do
      :ok ->
        {:noreply, socket |> redirect(to: ~p"/")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete account")
         |> push_navigate(to: ~p"/settings")}
    end
  end
end

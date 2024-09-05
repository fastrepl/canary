defmodule CanaryWeb.SettingsLive.AccountForm do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 id="account">Account</h2>

      <.form :let={f} for={@form} phx-submit="submit" phx-target={@myself} class="flex flex-col gap-4">
        <input
          type="text"
          name={f[:name].name}
          value={f[:name].value}
          class="input input-bordered w-full"
        />

        <div class="flex flex-row gap-2 justify-end">
          <button type="submit" class="btn btn-neutral btn-sm">
            <%= @submit_text %>
          </button>
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
      |> assign(:submit_text, "Update")

    {:ok, socket}
  end

  defp assign_form(socket) do
    form =
      socket.assigns.current_account
      |> AshPhoenix.Form.for_update(:update_name)
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
end

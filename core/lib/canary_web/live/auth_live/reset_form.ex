defmodule CanaryWeb.AuthLive.ResetForm do
  use CanaryWeb, :live_component
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@form}
        phx-target={@myself}
        phx-submit="submit"
        action={@action}
        class="flex flex-col justify-center gap-4"
      >
        <input type="hidden" name={f[:reset_token].name} value={@token} />
        <Primer.text_input
          type="password"
          placeholder="password"
          form={f}
          field={:password}
          disabled={@sent?}
          is_large
        />
        <Primer.text_input
          type="password"
          placeholder="password confirmation"
          form={f}
          field={:password_confirmation}
          disabled={@sent?}
          is_large
        />
        <button class="btn btn-neutral" type="submit">Recover</button>
        <div class="justify-end">
          <.link navigate={@alternative_path}>
            <%= @alternative_message %>
          </.link>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:sent?, false)}
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        socket = socket |> redirect(to: ~p"/sign-in")

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> assign(:form, AshPhoenix.Form.clear_value(form, [:password, :password_confirmation]))

        {:noreply, socket}
    end
  end
end

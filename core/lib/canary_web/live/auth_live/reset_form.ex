defmodule CanaryWeb.AuthLive.ResetForm do
  use CanaryWeb, :live_component

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
        class="flex flex-col justify-center gap-4 px-10 py-10 lg:px-16"
      >
        <input type="hidden" name={f[:reset_token].name} value={@token} />
        <div class="form-control">
          <label class="label" for="input1"><span class="label-text">Password</span></label>
          <input
            name={f[:password].name}
            value={f[:password].value}
            disabled={@sent?}
            type="password"
            placeholder="password"
            class="input input-bordered [&:user-invalid]:input-warning [&:user-valid]:input-success"
            required
            id="input1"
          />

          <label class="label" for="input1"><span class="label-text">Confirm Password</span></label>
          <input
            name={f[:password_confirmation].name}
            value={f[:password_confirmation].value}
            disabled={@sent?}
            type="password"
            placeholder="password"
            class="input input-bordered [&:user-invalid]:input-warning [&:user-valid]:input-success"
            required
            id="input1"
          />
        </div>
        <button class="btn btn-neutral" type="submit">Recover</button>
        <div class="label justify-end">
          <.link class="link-hover link label-text-alt" navigate={@alternative_path}>
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

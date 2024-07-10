defmodule CanaryWeb.AuthLive.ResetRequestForm do
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
        <%= if @sent? do %>
          <div class="alert alert-success text-xs">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 shrink-0 stroke-current"
              fill="none"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            <span>Recovery email sent successfully</span>
          </div>
        <% end %>
        <div class="form-control">
          <label class="label" for="input1"><span class="label-text">Email</span></label>
          <input
            name={f[:email].name}
            value={f[:email].value}
            disabled={@sent?}
            type="email"
            placeholder="email"
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
  def handle_event("submit", %{"user" => user}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: user) do
      {:ok, _} ->
        {:noreply, socket |> assign(:sent?, true)}

      {:error, form} ->
        {:noreply, socket |> assign(:form, AshPhoenix.Form.clear_value(form, [:email]))}
    end
  end
end

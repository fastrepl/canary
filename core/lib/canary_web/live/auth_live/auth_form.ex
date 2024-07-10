defmodule CanaryWeb.AuthLive.AuthForm do
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
        <div class="form-control">
          <label class="label" for="input1"><span class="label-text">Email</span></label>
          <input
            name={f[:email].name}
            value={f[:email].value}
            type="email"
            placeholder="email"
            class="input input-bordered [&:user-invalid]:input-warning [&:user-valid]:input-success"
            id="input1"
          />
        </div>
        <div class="form-control">
          <label class="label" for="input2"><span class="label-text">Password</span></label>
          <input
            name={f[:password].name}
            value={f[:password].value}
            type="password"
            placeholder="password"
            class="input input-bordered [&:user-invalid]:input-warning [&:user-valid]:input-success"
            minlength="6"
            for="input2"
          />
        </div>

        <%= if @register? do %>
          <div class="form-control">
            <label class="label" for="input3"><span class="label-text">Confirm Password</span></label>
            <input
              name={f[:password_confirmation].name}
              value={f[:password_confirmation].value}
              type="password"
              placeholder="confirm password"
              class="input input-bordered [&:user-invalid]:input-warning [&:user-valid]:input-success"
              minlength="6"
              for="input3"
            />
          </div>
        <% end %>

        <div class="flex items-center">
          <%= if not @register? do %>
            <div class="label">
              <a class="link-hover link label-text-alt" href="/reset-request">Forgot password?</a>
            </div>
          <% end %>
          <.link class="link-hover link label-text-alt ml-auto" navigate={@alternative_path}>
            <%= @alternative_message %>
          </.link>
        </div>

        <button class="btn btn-neutral" type="submit">Login</button>

        <%= if Application.get_env(:canary, :github)[:enabled?] do %>
          <button class="btn" type="button" phx-click="github" phx-target={@myself}>
            <svg height="18" viewBox="0 0 16 16" width="32px">
              <path
                fill-rule="evenodd"
                d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38
      0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01
      1.08.58 1.23.82.72 1.21 1.87.87
      2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12
      0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08
      2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0
      .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"
              />
            </svg>
            Login with GitHub
          </button>
        <% end %>

        <div class="label justify-end"></div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def handle_event("submit", %{"user" => user}, socket) do
    case AshPhoenix.Form.submit(
           socket.assigns.form,
           params: user,
           read_one?: true,
           before_submit: &Ash.Changeset.set_context(&1, %{token_type: :sign_in})
         ) do
      {:ok, user} ->
        to = "/auth/user/password/sign_in_with_token?token=#{user.__metadata__.token}"
        {:noreply, socket |> redirect(to: to)}

      {:error, form} ->
        socket = socket |> assign(:form, AshPhoenix.Form.clear_value(form, [:password]))
        {:noreply, socket}
    end
  end

  def handle_event("github", _, socket) do
    {:noreply, socket |> redirect(to: "/auth/user/github")}
  end
end

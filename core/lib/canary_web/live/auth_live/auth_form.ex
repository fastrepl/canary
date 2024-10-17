defmodule CanaryWeb.AuthLive.AuthForm do
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
        <Primer.text_input
          autocomplete="off"
          type="email"
          placeholder="email"
          form={f}
          field={:email}
          is_large
        />
        <Primer.text_input
          autocomplete="off"
          type="password"
          placeholder="password"
          form={f}
          field={:password}
          is_large
        />

        <%= if @register? do %>
          <Primer.text_input
            autocomplete="off"
            type="password"
            placeholder="password confirmation"
            form={f}
            field={:password_confirmation}
            is_large
          />
        <% end %>

        <div class="flex items-center">
          <%= if not @register? do %>
            <.link navigate={~p"/reset-request"}>Forgot password?</.link>
          <% end %>
          <.link class="ml-auto" navigate={@alternative_path}>
            <%= @alternative_message %>
          </.link>
        </div>

        <Primer.button type="submit" is_primary>Login</Primer.button>

        <%= if Application.get_env(:canary, :github)[:enabled?] do %>
          <Primer.button type="button" phx-click="github" phx-target={@myself}>
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
          </Primer.button>
        <% end %>
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

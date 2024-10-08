defmodule CanaryWeb.AuthLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col min-h-screen items-center justify-center gap-4">
      <div>🐤</div>
      <div class="w-full max-w-sm md:max-w-lg">
        <.live_component
          module={
            cond do
              @live_action == :reset_request -> CanaryWeb.AuthLive.ResetRequestForm
              @live_action == :reset -> CanaryWeb.AuthLive.ResetForm
              true -> CanaryWeb.AuthLive.AuthForm
            end
          }
          id={@id}
          form={@form}
          register?={@live_action == :register}
          alternative_path={@alternative_path}
          alternative_message={@alternative_message}
          action={@action}
          token={assigns[:token]}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :register, _params) do
    socket
    |> assign(:id, "register-form")
    |> assign(:alternative_path, ~p"/sign-in")
    |> assign(:alternative_message, "Have an account?")
    |> assign(:main_message, "Create new account")
    |> assign(:action, ~p"/auth/user/password/register")
    |> assign(
      :form,
      AshPhoenix.Form.for_create(Canary.Accounts.User, :register_with_password,
        domain: Canary.Accounts,
        as: "user"
      )
      |> to_form()
    )
  end

  defp apply_action(socket, :sign_in, _params) do
    socket
    |> assign(:id, "sign-in-form")
    |> assign(:alternative_path, ~p"/register")
    |> assign(:alternative_message, "Need an account?")
    |> assign(:main_message, "Login to your account")
    |> assign(:action, ~p"/auth/user/password/sign_in")
    |> assign(
      :form,
      AshPhoenix.Form.for_action(Canary.Accounts.User, :sign_in_with_password,
        domain: Canary.Accounts,
        as: "user"
      )
      |> to_form()
    )
  end

  defp apply_action(socket, :reset_request, _params) do
    socket
    |> assign(:id, "reset-request-form")
    |> assign(:alternative_path, ~p"/register")
    |> assign(:alternative_message, "Need an account?")
    |> assign(:main_message, "Reset your password")
    |> assign(:action, ~p"/auth//user/password/reset_request")
    |> assign(
      :form,
      AshPhoenix.Form.for_action(Canary.Accounts.User, :request_password_reset_with_password,
        domain: Canary.Accounts,
        as: "user"
      )
      |> to_form()
    )
  end

  defp apply_action(socket, :reset, params) do
    socket =
      socket
      |> assign(:id, "reset-form")
      |> assign(:alternative_path, ~p"/register")
      |> assign(:alternative_message, "Need an account?")
      |> assign(:main_message, "Reset your password")
      |> assign(:action, ~p"/auth//user/password/reset")
      |> assign(:token, params["token"])

    with {:ok, %{"sub" => subject}, resource} <-
           AshAuthentication.Jwt.verify(params["token"], Canary.Accounts.User),
         {:ok, user} <-
           AshAuthentication.subject_to_user(subject, resource) do
      socket
      |> assign(
        :form,
        AshPhoenix.Form.for_action(user, :password_reset_with_password,
          domain: Canary.Accounts,
          as: "user"
        )
        |> to_form()
      )
    else
      _ ->
        socket |> redirect(to: ~p"/sign-in")
    end
  end
end

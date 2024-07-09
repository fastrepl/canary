defmodule CanaryWeb.AuthLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen items-center justify-center bg-base-200">
      <div class="m-4 min-h-[50vh] w-full max-w-sm lg:max-w-4xl">
        <div class="flex items-center justify-center gap-2 p-8">
          <span>🐤</span>
          <h1 class="text-lg font-bold"><%= @main_message %></h1>
        </div>
        <main class="grid bg-base-100 lg:aspect-[2/1] lg:grid-cols-2">
          <figure class="pointer-events-none bg-base-300 object-cover max-lg:hidden">
            <img src="https://picsum.photos/id/222/1200/1200?blur" alt="Login" class="h-full" />
          </figure>
          <.live_component
            module={CanaryWeb.AuthLive.AuthForm}
            id={@id}
            form={@form}
            register?={@live_action == :register}
            alternative_path={@alternative_path}
            alternative_message={@alternative_message}
            action={@action}
          />
        </main>
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
    )
  end
end

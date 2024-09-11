defmodule CanaryWeb.OnboardingLive do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto mt-[100px]">
      <div class="mb-8">
        <h1 class="text-2xl font-semibold">
          🐤 Canary Onboarding
        </h1>
        <p>Please follow the steps below.</p>
      </div>

      <.form
        :let={f}
        id="account-form"
        for={@account_form}
        phx-submit="account"
        class="flex flex-col gap-2"
      >
        <input type="hidden" name={f[:user_id].name} value={@current_user.id} />
        <Primer.text_input form={f} field={:name} is_large form_control={%{label: "Name"}} />
        <Primer.button type="submit">
          Submit
        </Primer.button>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        :account_form,
        AshPhoenix.Form.for_create(Canary.Accounts.Account, :create) |> to_form()
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("account", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.account_form, params: params) do
      {:ok, _} ->
        {:noreply, socket |> redirect(to: ~p"/")}

      {:error, form} ->
        IO.inspect(form)
        {:noreply, assign(socket, :account_form, form)}
    end
  end
end

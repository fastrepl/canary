defmodule CanaryWeb.OnboardingLive.FirstAccount do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-gray-200 py-4 px-6 rounded-md">
      <h2>Let's create your first organization!</h2>

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <input type="hidden" name={@form[:user_id].name} value={@current_user.id} />
        <.input field={@form[:name]} label="Name" />
        <.button type="submit">Save</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    form =
      Canary.Accounts.Account
      |> AshPhoenix.Form.for_create(:create, forms: [auto?: true])
      |> to_form()

    socket =
      socket
      |> assign(assigns)
      |> assign(:form, form)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} -> {:noreply, socket |> push_navigate(to: ~p"/")}
      {:error, form} -> {:noreply, socket |> assign(:form, form)}
    end
  end
end

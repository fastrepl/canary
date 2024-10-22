defmodule CanaryWeb.SettingsLive.Account do
  use CanaryWeb, :live_component

  @impl true
  def render(%{owner?: true} = assigns) do
    ~H"""
    <div>
      <h2>Account</h2>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <input type="hidden" name={@form[:user_id].name} value={@current_user.id} />
        <.input field={@form[:name]} label="Name" />
        <.button type="submit">Save</.button>
      </.form>
    </div>
    """
  end

  def render(%{owner?: false} = assigns) do
    ~H"""
    <div>
      <h2>Account</h2>
      <div>Only owner can update account info.</div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    current_account = assigns.current_account |> Ash.load!(:owner)
    owner? = current_account.owner.id == assigns.current_user.id

    socket =
      socket
      |> assign(assigns)
      |> assign_form()
      |> assign(:owner?, owner?)

    {:ok, socket}
  end

  defp assign_form(socket) do
    form =
      socket.assigns.current_account
      |> AshPhoenix.Form.for_update(:update)
      |> to_form()

    socket |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _} ->
        {:noreply, socket |> push_navigate(to: ~p"/settings")}

      {:error, form} ->
        IO.inspect(form)
        {:noreply, socket |> assign(:form, form)}
    end
  end
end

defmodule CanaryWeb.SettingsLive.Account do
  use CanaryWeb, :live_component

  @impl true
  def render(%{owner?: true} = assigns) do
    ~H"""
    <div>
      <h2>Account</h2>
      You are the owner.
    </div>
    """
  end

  def render(%{owner?: false} = assigns) do
    ~H"""
    <div>
      <h2>Account</h2>
      You are not owner.
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
end

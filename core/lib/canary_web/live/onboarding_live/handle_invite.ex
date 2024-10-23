defmodule CanaryWeb.OnboardingLive.HandleInvite do
  use CanaryWeb, :live_component

  @reject "__NONE__"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-gray-200 py-4 px-6 rounded-md">
      <h2 class="mb-2">You have an invite!</h2>

      <form phx-target={@myself} phx-submit="save" class="flex flex-col gap-2">
        <fieldset class="flex flex-col gap-4">
          <legend class="mb-3">Choose one:</legend>

          <div :for={invite <- @invites} class="flex flex-row gap-2 items-center">
            <input type="radio" id={invite.account.name} name="decision" value={invite.account.name} />
            <label for={invite.account.name}>
              Accept invite from
              <span class="p-1 bg-yellow-100 rounded-md"><%= invite.account.name %></span>
            </label>
          </div>

          <div>
            <input type="radio" id={@reject} name="decision" value={@reject} checked />
            <label for={@reject} class="p-1 bg-gray-100 rounded-md">
              Ignore all invites and discard them.
            </label>
          </div>
        </fieldset>

        <.button type="submit" is_primary class="mt-4 w-full">Save</.button>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    invites =
      Canary.Accounts.Invite
      |> Ash.Query.for_read(:not_expired, %{}, actor: assigns.current_user)
      |> Ash.read!(load: [:account])

    if invites == [] do
      send(assigns.view_pid, :no_invites)
    end

    socket =
      socket
      |> assign(assigns)
      |> assign(:invites, invites)
      |> assign(:reject, @reject)

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"decision" => @reject}, socket) do
    case Canary.Accounts.Invite
         |> Ash.Query.for_read(:not_expired, %{}, actor: socket.assigns.current_user)
         |> Ash.bulk_destroy(:destroy, %{},
           return_errors?: true,
           actor: socket.assigns.current_user
         ) do
      %Ash.BulkResult{status: :success} ->
        socket =
          socket
          |> put_flash(:info, "All invites have been discarded!")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      %Ash.BulkResult{errors: _errors} ->
        socket =
          socket
          |> put_flash(:error, "Failed to discard all invites")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}
    end
  end

  def handle_event("save", %{"decision" => decision}, socket) do
    invite = socket.assigns.invites |> Enum.find(&(&1.account.name == decision))
    current_user = socket.assigns.current_user

    with {:ok, _} <- Canary.Accounts.Account.add_member(invite.account, current_user.id),
         {:ok, _} <- Ash.destroy(invite, return_destroyed?: false, actor: current_user) do
      socket
      |> put_flash(:info, "Invite has been accepted!")
      |> push_navigate(to: ~p"/")

      {:noreply, socket}
    else
      error ->
        socket
        |> put_flash(:error, error)
        |> push_navigate(to: ~p"/")

        {:noreply, socket}
    end
  end
end

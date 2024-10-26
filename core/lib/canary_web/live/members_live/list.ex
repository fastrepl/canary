defmodule CanaryWeb.MembersLive.List do
  use CanaryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="min-w-full bg-white border border-gray-300">
        <thead>
          <tr class="bg-gray-100">
            <th
              :for={name <- ["Email", "Role", "Status", "Action"]}
              class="py-2 px-4 border-b text-left"
            >
              <%= name %>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr :for={user <- @current_account.users}>
            <td class="py-2 px-4 border-b"><%= user.email %></td>
            <td class="py-2 px-4 border-b">
              <%= if user.email == @current_account.owner.email, do: "Owner", else: "Member" %>
            </td>
            <td class="py-2 px-4 border-b">
              <%= if user.confirmed_at, do: "Confirmed", else: "Unconfirmed" %>
            </td>
            <td class="py-2 px-4 border-b">None</td>
          </tr>
          <tr :for={invite <- @invites}>
            <td class="py-2 px-4 border-b"><%= invite.email %></td>
            <td class="py-2 px-4 border-b">Member</td>
            <td class="py-2 px-4 border-b">Pending</td>
            <td class="py-2 px-4 border-b">
              <.button
                type="button"
                phx-target={@myself}
                phx-click="destroy"
                phx-value-invite={invite.id}
              >
                Cancel
              </.button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    invites =
      Canary.Accounts.Invite
      |> Ash.Query.for_read(:not_expired, %{}, actor: assigns.current_account)
      |> Ash.read!()

    socket =
      socket
      |> assign(assigns)
      |> assign(:invites, invites)

    {:ok, socket}
  end

  @impl true
  def handle_event("destroy", %{"invite" => invite_id}, socket) do
    actor = socket.assigns.current_account

    with {:ok, record} <- Ash.get(Canary.Accounts.Invite, invite_id, actor: actor),
         :ok <- Ash.destroy(record, return_destroyed?: false, actor: actor) do
      socket =
        socket
        |> put_flash(:info, "Invite has been cancelled!")
        |> push_navigate(to: ~p"/members")

      {:noreply, socket}
    else
      error ->
        socket =
          socket
          |> put_flash(:error, error)
          |> push_navigate(to: ~p"/members")

        {:noreply, socket}
    end
  end
end

defmodule CanaryWeb.MembersLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2>Members</h2>

      <.button phx-click={show_modal("invite-member-modal")}>Invite a new member</.button>

      <.modal id="invite-member-modal" on_cancel={JS.navigate(~p"/members")}>
        <.live_component
          id="invite-form"
          module={CanaryWeb.MembersLive.Invite}
          current_account={@current_account}
        />
      </.modal>

      <div class="overflow-x-auto">
        <table class="min-w-full bg-white border border-gray-300">
          <thead>
            <tr class="bg-gray-100">
              <th :for={name <- ["Email", "Role", "Status"]} class="py-2 px-4 border-b text-left">
                <%= name %>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class="py-2 px-4 border-b">yujonglee@fastrepl.com</td>
              <td class="py-2 px-4 border-b">Owner</td>
              <td class="py-2 px-4 border-b">Active</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_account = socket.assigns.current_account |> Ash.load!([:owner, :users])

    invites =
      Canary.Accounts.Invite
      |> Ash.Query.for_read(:not_expired, %{}, actor: current_account)
      |> Ash.read!()

    socket =
      socket
      |> assign(current_account: current_account)
      |> assign(:invites, invites)

    {:ok, socket}
  end
end

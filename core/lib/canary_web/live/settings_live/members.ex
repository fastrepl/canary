defmodule CanaryWeb.SettingsLive.Members do
  use CanaryWeb, :live_view
  require Ash.Query

  alias PrimerLive.Component, as: Primer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Primer.subhead>
        Members
        <:actions>
          <Primer.button is_primary phx-click={Primer.open_dialog("invite-form")}>
            Invite
          </Primer.button>
        </:actions>
      </Primer.subhead>

      <Primer.box is_scrollable style="max-height: 500px; margin-top: 18px">
        <:row :for={user <- @current_account.users}>
          <div class="flex flex-row justify-between">
            <span><%= user.email %></span>
            <span>
              <%= if(user.email == @current_account.owner.email, do: "Owner", else: "Member") %>
            </span>
          </div>
        </:row>
        <:row :for={invite <- @invites}>
          <div class="flex flex-row justify-between">
            <span><%= invite.email %></span>
            <span>Pending</span>
          </div>
        </:row>
      </Primer.box>

      <Primer.dialog id="invite-form" is_backdrop>
        <:header_title>Invite</:header_title>
        <:body>
          <.live_component
            id="invite-form"
            module={CanaryWeb.SettingsLive.MemberInvite}
            current_account={@current_account}
          />
        </:body>
      </Primer.dialog>
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

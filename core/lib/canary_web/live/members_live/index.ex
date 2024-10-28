defmodule CanaryWeb.MembersLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-col mb-2">
        <div class="flex flex-row items-center justify-between">
          <h2>Members</h2>
          <.button phx-click={show_modal("invite-member-modal")} is_primary>Invite</.button>
        </div>
        <p>
          Members can access all projects, and can invite other members.
        </p>
      </div>

      <.modal id="invite-member-modal" on_cancel={JS.navigate(~p"/members")}>
        <.live_component
          id="members-invite-form"
          module={CanaryWeb.MembersLive.Invite}
          current_account={@current_account}
        />
      </.modal>

      <.live_component
        id="members-list"
        module={CanaryWeb.MembersLive.List}
        current_account={@current_account}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_account = socket.assigns.current_account |> Ash.load!([:owner, :users])
    socket = socket |> assign(current_account: current_account)
    {:ok, socket}
  end
end

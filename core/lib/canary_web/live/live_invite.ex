defmodule CanaryWeb.LiveInvite do
  use CanaryWeb, :verified_routes

  def on_mount(_, _params, _session, socket) do
    invite =
      Canary.Accounts.Invite
      |> Ash.Query.for_read(:not_expired, %{}, actor: socket.assigns.current_user)
      |> Ash.read_one!()

    if not is_nil(invite) do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/onboarding?invite=true")}
    else
      {:cont, socket}
    end
  end
end

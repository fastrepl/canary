defmodule CanaryWeb.LiveAccount do
  import Phoenix.Component
  use CanaryWeb, :verified_routes

  require Ash.Query

  def on_mount(_, _params, _session, socket) do
    if socket.assigns[:current_account] do
      {:cont, socket}
    else
      {:cont, assign_current_account(socket)}
    end
  end

  defp assign_current_account(socket) do
    accounts =
      socket.assigns[:current_user]
      |> Ash.load!(:accounts)
      |> Map.get(:accounts)

    account =
      if length(accounts) == 0 do
        handle_empty_accounts(socket)
      else
        Enum.at(accounts, 0)
      end

    socket |> assign(:current_account, account)
  end

  defp handle_empty_accounts(socket) do
    invite =
      Canary.Accounts.Invite
      |> Ash.Query.for_read(:not_expired, %{}, actor: socket.assigns.current_user)
      |> Ash.read_one!()

    if not is_nil(invite) do
      invite = invite |> Ash.load!(:account)

      with invite <- invite |> Ash.load!(:account),
           :ok <- Ash.destroy(invite),
           {:ok, _} <-
             Canary.Accounts.Account.add_member(invite.account, socket.assigns[:current_user].id) do
        invite.account
      end
    else
      Canary.Accounts.Account
      |> Ash.Changeset.for_create(:create, %{user_id: socket.assigns[:current_user].id})
      |> Ash.create!()
    end
  end
end

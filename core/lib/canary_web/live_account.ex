defmodule CanaryWeb.LiveAccount do
  import Phoenix.Component
  use CanaryWeb, :verified_routes

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
        Canary.Accounts.Account
        |> Ash.Changeset.for_create(:create, %{user_id: socket.assigns[:current_user].id})
        |> Ash.create!()
      else
        Enum.at(accounts, 0)
      end

    socket |> assign(:current_account, account)
  end
end

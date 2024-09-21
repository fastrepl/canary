defmodule CanaryWeb.LiveUserAuth do
  import Phoenix.Component
  use CanaryWeb, :verified_routes

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket |> assign(:current_account, current_account(socket))}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket |> assign(:current_account, current_account(socket))}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  defp current_account(socket) do
    accounts =
      socket.assigns[:current_user]
      |> Ash.load!(:accounts)
      |> Map.get(:accounts)

    if length(accounts) == 0 do
      Canary.Accounts.Account
      |> Ash.Changeset.for_create(:create, %{user_id: socket.assigns[:current_user].id})
      |> Ash.create!()
    else
      Enum.at(accounts, 0)
    end
  end
end

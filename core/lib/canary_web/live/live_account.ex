defmodule CanaryWeb.LiveAccount do
  use CanaryWeb, :verified_routes
  import Phoenix.Component

  require Ash.Query

  def on_mount(:live_account_optional, _params, _session, socket) do
    socket = socket.assigns[:current_account] || select_from_existing_accounts(socket)

    {:cont, socket}
  end

  def on_mount(:live_account_required, _params, _session, socket) do
    socket = socket.assigns[:current_account] || select_from_existing_accounts(socket)

    if socket.assigns[:current_account] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/onboarding")}
    end
  end

  defp select_from_existing_accounts(socket) do
    current_user = socket.assigns[:current_user]
    accounts = current_user |> Ash.load!(accounts: [:owner_email_confirmed]) |> Map.get(:accounts)

    current_account =
      Enum.find(accounts, &(&1.id == current_user.selected_account_id)) ||
        Enum.at(accounts, 0, nil)

    socket |> assign(:current_account, current_account)
  end
end

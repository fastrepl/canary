defmodule CanaryWeb.SubdomainMountLive do
  import Phoenix.Component

  def on_mount(:current_account, _params, session, socket) do
    account_id = session["account_id"]

    if account_id do
      account = Ash.get!(Canary.Accounts.Account, account_id, load: [:subdomain])
      {:cont, socket |> assign(:current_account, account)}
    else
      {:halt, Phoenix.LiveView.redirect(socket, external: "https://getcanary.dev")}
    end
  end
end

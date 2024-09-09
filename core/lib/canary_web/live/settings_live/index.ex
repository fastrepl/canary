defmodule CanaryWeb.SettingsLive.Index do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @forms [
    %{
      id: "settings-account-form",
      module: CanaryWeb.SettingsLive.AccountForm
    },
    %{
      id: "settings-key-form",
      module: CanaryWeb.SettingsLive.KeyForm
    },
    %{
      id: "settings-billing-form",
      module: CanaryWeb.SettingsLive.BillingForm
    },
    %{
      id: "settings-subdomain-form",
      module: CanaryWeb.SettingsLive.SubdomainForm
    }
  ]

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <%= for %{id: id, module: module} <- @forms do %>
        <.live_component id={id} module={module} current_account={@current_account} />
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:billing, :keys])

    socket =
      socket
      |> assign(:current_account, account)
      |> assign(:forms, @forms)

    {:ok, socket}
  end
end

defmodule CanaryWeb.SettingsLive.Index do
  use CanaryWeb, :live_view

  @forms [
    %{
      id: "settings-account-form",
      module: CanaryWeb.SettingsLive.AccountForm
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
    <div>
      <%= for {%{id: id, module: module}, index} <- Enum.with_index(@forms) do %>
        <%= if index != 0 do %>
          <hr class="my-8" />
        <% end %>
        <.live_component id={id} module={module} current_account={@current_account} />
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:billing])

    socket =
      socket
      |> assign(:current_account, account)
      |> assign(:forms, @forms)

    {:ok, socket}
  end
end

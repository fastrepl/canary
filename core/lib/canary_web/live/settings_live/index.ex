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
      <%= for %{id: id, module: module} <- @forms do %>
        <hr />
        <.live_component id={id} module={module} current_account={@current_account} />
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:forms, @forms)}
  end
end

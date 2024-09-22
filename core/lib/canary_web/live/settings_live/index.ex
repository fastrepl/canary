defmodule CanaryWeb.SettingsLive.Index do
  use CanaryWeb, :live_view
  alias PrimerLive.Component, as: Primer

  @user_forms [
    %{
      id: "settings-user-form",
      module: CanaryWeb.SettingsLive.UserForm
    }
  ]

  @org_forms [
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
    }
  ]

  def render(assigns) do
    ~H"""
    <Primer.tabnav aria_label="Tabs">
      <:item :for={tab <- @tabs} is_selected={tab == @tab} phx-click="set-tab" phx-value-item={tab}>
        <%= tab %>
      </:item>
    </Primer.tabnav>

    <div class="flex flex-col gap-4 mt-6">
      <%= for %{id: id, module: module} <- if(@tab == "User", do: @user_forms, else: @org_forms) do %>
        <.live_component
          id={id}
          module={module}
          current_user={@current_user}
          current_account={@current_account}
        />
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Ash.load!([:billing, :keys])

    socket =
      socket
      |> assign(:current_account, account)
      |> assign(:user_forms, @user_forms)
      |> assign(:org_forms, @org_forms)
      |> assign(:tabs, ["User", "Organization"])
      |> assign(:tab, "User")

    {:ok, socket}
  end

  def handle_event("set-tab", %{"item" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end
end

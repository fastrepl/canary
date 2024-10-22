defmodule CanaryWeb.SettingsLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        id="settings-account"
        module={CanaryWeb.SettingsLive.Account}
        current_user={@current_user}
        current_account={@current_account}
      />

      <.live_component
        id="settings-project"
        module={CanaryWeb.SettingsLive.Project}
        current_project={@current_project}
      />

      <.live_component
        id="settings-user"
        module={CanaryWeb.SettingsLive.User}
        current_user={@current_user}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

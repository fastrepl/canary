defmodule CanaryWeb.SettingsLive.Index do
  use CanaryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <%= render_account(assigns) %>
      <%= render_project(assigns) %>
      <%= render_user(assigns) %>
    </div>
    """
  end

  defp render_account(%{owner?: true} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <h2>Organization</h2>
      <.live_component
        id="settings-account"
        module={CanaryWeb.SettingsLive.Account}
        current_user={@current_user}
        current_account={@current_account}
      />
    </div>
    """
  end

  defp render_account(%{owner?: false} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <h2>Organization</h2>
      <p>Only owner can update the info.</p>
    </div>
    """
  end

  defp render_project(%{owner?: true} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <h2>Project</h2>
      <.live_component
        id="settings-project"
        module={CanaryWeb.SettingsLive.Project}
        current_user={@current_user}
        current_account={@current_account}
        current_project={@current_project}
      />
    </div>
    """
  end

  defp render_project(%{owner?: false} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <h2>Project</h2>
      <p>Only owner can update the info.</p>
    </div>
    """
  end

  defp render_user(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <h2>User</h2>
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
    current_account = socket.assigns.current_account |> Ash.load!(:owner)
    owner? = current_account.owner.id == socket.assigns.current_user.id

    {:ok, assign(socket, owner?: owner?)}
  end
end

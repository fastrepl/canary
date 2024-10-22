defmodule CanaryWeb.LiveProject do
  import Phoenix.Component
  use CanaryWeb, :verified_routes

  def on_mount(:live_project_optional, _params, _session, socket) do
    if not is_nil(socket.assigns[:current_project]) do
      {:cont, socket}
    else
      {:cont, select_from_existing_projects(socket)}
    end
  end

  def on_mount(:live_project_required, _params, _session, socket) do
    socket = select_from_existing_projects(socket)

    if not is_nil(socket.assigns[:current_project]) do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/onboarding")}
    end
  end

  defp select_from_existing_projects(socket) do
    if socket.assigns[:current_account] do
      account = socket.assigns[:current_account] |> Ash.load!(:projects)
      projects = account.projects
      current_project = Enum.find(projects, & &1.selected) || Enum.at(projects, 0)

      socket
      |> assign(:current_account, account)
      |> assign(:current_projects, projects)
      |> assign(:current_project, current_project)
    else
      socket
      |> assign(:current_projects, [])
      |> assign(:current_project, nil)
    end
  end
end

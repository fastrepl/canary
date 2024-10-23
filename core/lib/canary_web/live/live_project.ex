defmodule CanaryWeb.LiveProject do
  import Phoenix.Component
  use CanaryWeb, :verified_routes

  def on_mount(:live_project_optional, _params, _session, socket) do
    socket = socket.assigns[:current_project] || select_from_existing_projects(socket)

    {:cont, socket}
  end

  def on_mount(:live_project_required, _params, _session, socket) do
    socket = socket.assigns[:current_project] || select_from_existing_projects(socket)

    if socket.assigns[:current_project] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/onboarding")}
    end
  end

  defp select_from_existing_projects(socket) do
    if socket.assigns[:current_account] do
      current_user = socket.assigns[:current_user]
      current_account = socket.assigns[:current_account] |> Ash.load!(:projects)

      current_project =
        Enum.find(current_account.projects, &(&1.id == current_user.selected_project_id)) ||
          Enum.at(current_account.projects, 0)

      socket
      |> assign(:current_account, current_account)
      |> assign(:current_projects, current_account.projects)
      |> assign(:current_project, current_project)
    else
      socket
      |> assign(:current_projects, [])
      |> assign(:current_project, nil)
    end
  end
end

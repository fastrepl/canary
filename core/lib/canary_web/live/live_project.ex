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
      account = socket.assigns[:current_account] |> Ash.load!(:projects)
      socket = socket |> assign(:current_account, account)
      project = account.projects |> Enum.find(& &1.selected)

      cond do
        account.projects == [] ->
          {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/onboarding")}

        is_nil(project) ->
          project = account.projects |> Enum.at(0)
          Canary.Accounts.Project.select(project, account.id)
          {:cont, socket |> assign(:current_project, project)}

        true ->
          {:cont, socket |> assign(:current_project, project)}
      end
    end
  end

  defp select_from_existing_projects(socket) do
    if socket.assigns[:current_account] do
      account = socket.assigns[:current_account] |> Ash.load!(:projects)

      socket
      |> assign(:current_account, account)
      |> assign(:current_projects, account.projects)
      |> assign(:current_project, Enum.at(account.projects, 0, nil))
    else
      socket
      |> assign(:current_projects, [])
      |> assign(:current_project, nil)
    end
  end
end

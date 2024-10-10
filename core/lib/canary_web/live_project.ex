defmodule CanaryWeb.LiveProject do
  import Phoenix.Component
  use CanaryWeb, :verified_routes

  def on_mount(:live_project_optional, _params, _session, socket) do
    if not is_nil(socket.assigns[:current_project]) do
      {:cont, socket}
    else
      {:cont, socket |> assign(:current_project, nil)}
    end
  end

  def on_mount(:live_project_required, _params, _session, socket) do
    if not is_nil(socket.assigns[:current_project]) do
      {:cont, socket}
    else
      projects = socket.assigns[:current_account] |> Ash.load!(:projects) |> Map.get(:projects)

      if projects != [] do
        {:cont, socket |> assign(:current_project, Enum.at(projects, 0))}
      else
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/settings/projects")}
      end
    end
  end
end

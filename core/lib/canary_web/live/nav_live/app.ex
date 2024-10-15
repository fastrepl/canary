defmodule CanaryWeb.NaveLive.App do
  import Phoenix.LiveView
  use Phoenix.Component

  def on_mount(_, _params, _session, socket) do
    socket =
      socket
      |> attach_hook(:app_active_tab, :handle_params, &set_active_tab/3)
      |> attach_hook(:app_project_change, :handle_event, &handle_event/3)

    {:cont, socket}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case socket.view do
        CanaryWeb.HomeLive -> :home
        CanaryWeb.SourceLive.Index -> :source
        CanaryWeb.InsightLive -> :insight
        _ -> nil
      end

    {:cont, socket |> assign(app_active_tab: active_tab)}
  end

  def handle_event("project-change", %{"current-project" => project_name}, socket) do
    project = socket.assigns.current_account.projects |> Enum.find(&(&1.name == project_name))
    account_id = socket.assigns.current_account.id

    {:ok, _} = Canary.Accounts.Project.select(project, account_id)
    {:halt, socket |> push_navigate(to: "/")}
  end

  def handle_event(_, _, socket), do: {:cont, socket}
end

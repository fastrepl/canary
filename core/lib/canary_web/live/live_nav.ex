defmodule CanaryWeb.LiveNav do
  import Phoenix.LiveView
  use Phoenix.Component
  use CanaryWeb, :verified_routes

  def on_mount(_, _params, _session, socket) do
    accounts =
      socket.assigns.current_user
      |> Ash.load!(accounts: [:name])
      |> Map.get(:accounts)

    current_account = socket.assigns.current_account

    projects = if is_nil(current_account), do: [], else: current_account.projects

    socket =
      socket
      |> attach_hook(:app_active_tab, :handle_params, &set_active_tab/3)
      |> attach_hook(:app_project_change, :handle_event, &handle_event/3)
      |> assign(:current_accounts, accounts)
      |> assign(:current_projects, projects)

    {:cont, socket}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case socket.view do
        CanaryWeb.OverviewLive.Index -> "Overview"
        CanaryWeb.SourceLive.Index -> "Sources"
        CanaryWeb.InsightLive.Index -> "Insights"
        CanaryWeb.OnboardingLive.Index -> "Onboarding"
        CanaryWeb.ProjectsLive.Index -> "Projects"
        CanaryWeb.MembersLive.Index -> "Members"
        CanaryWeb.BillingLive.Index -> "Billing"
        CanaryWeb.SettingsLive.Index -> "Settings"
        CanaryWeb.PlaygroundLive.Index -> "Playground"
        _ -> nil
      end

    {:cont, socket |> assign(app_active_tab: active_tab)}
  end

  def handle_event("account-change", %{"current-account" => account_id}, socket) do
    account = Enum.find(socket.assigns.current_accounts, &(&1.id == account_id))

    socket.assigns.current_user
    |> Ash.Changeset.for_update(:update, %{selected_account_id: account_id})
    |> Ash.update()

    socket =
      socket
      |> assign(:current_account, account)
      |> push_navigate(to: ~p"/")

    {:halt, socket}
  end

  def handle_event("project-change", %{"current-project" => project_id}, socket) do
    project = Enum.find(socket.assigns.current_account.projects, &(&1.id == project_id))

    socket.assigns.current_user
    |> Ash.Changeset.for_update(:update, %{selected_project_id: project_id})
    |> Ash.update()

    socket =
      socket
      |> assign(:current_project, project)
      |> push_navigate(to: ~p"/")

    {:halt, socket}
  end

  def handle_event(_, _, socket), do: {:cont, socket}
end

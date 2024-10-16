defmodule CanaryWeb.NaveLive.Settings do
  import Phoenix.LiveView
  use Phoenix.Component

  def on_mount(_, _params, _session, socket) do
    {:cont, socket |> attach_hook(:settings_active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case socket.view do
        CanaryWeb.SettingsLive.Account -> :account
        CanaryWeb.SettingsLive.Projects -> :projects
        CanaryWeb.SettingsLive.Members -> :members
        CanaryWeb.SettingsLive.Billing -> :billing
        _ -> nil
      end

    {:cont, socket |> assign(settings_active_tab: active_tab)}
  end
end

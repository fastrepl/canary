defmodule CanaryWeb.NavLive do
  import Phoenix.LiveView
  use Phoenix.Component

  def on_mount(_, _params, _session, socket) do
    {:cont, socket |> attach_hook(:active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case socket.view do
        CanaryWeb.HomeLive -> :home
        CanaryWeb.EditorLive -> :editor
        CanaryWeb.EditorHomeLive -> :editor
        CanaryWeb.InteractionsLive -> :interactions
        CanaryWeb.SettingsLive -> :settings
        _ -> nil
      end

    {:cont, socket |> assign(active_tab: active_tab)}
  end
end

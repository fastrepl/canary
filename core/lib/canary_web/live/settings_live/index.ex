defmodule CanaryWeb.SettingsLive.Index do
  use CanaryWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> push_navigate(to: ~p"/settings/account")}
  end
end

defmodule CanaryWeb.LiveOnboarding do
  def on_mount(_, _params, _session, socket) do
    {:cont, Phoenix.LiveView.attach_hook(socket, :onboarding?, :handle_params, &onboarding?/3)}
  end

  defp onboarding?(_params, url, socket) do
    {:cont, Phoenix.Component.assign(socket, :onboarding?, URI.parse(url).path == "/onboarding")}
  end
end

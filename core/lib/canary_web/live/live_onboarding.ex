defmodule CanaryWeb.LiveOnboarding do
  import Phoenix.Component

  def on_mount(_, _params, _session, socket) do
    onboarding? =
      cond do
        is_nil(socket.assigns[:current_account]) -> true
        is_nil(socket.assigns[:current_project]) -> true
        true -> true
      end

    {:cont, assign(socket, onboarding?: onboarding?)}
  end
end

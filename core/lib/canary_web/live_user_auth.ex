defmodule CanaryWeb.LiveUserAuth do
  import Phoenix.Component
  use CanaryWeb, :verified_routes

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      user = socket.assigns[:current_user]
      {:cont, socket |> assign(:current_user, Ash.load!(user, :accounts))}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      user = socket.assigns[:current_user]
      {:cont, socket |> assign(:current_user, Ash.load!(user, :accounts))}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end

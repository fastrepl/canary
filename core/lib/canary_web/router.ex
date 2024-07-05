defmodule CanaryWeb.Router do
  use CanaryWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CanaryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  scope "/", CanaryWeb do
    pipe_through :browser

    sign_in_route(
      register_path: "/register",
      overrides: [CanaryWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )

    sign_out_route(AuthController)
    auth_routes_for(Canary.Accounts.User, to: AuthController)
    reset_route([])
  end

  scope "/" do
    pipe_through :browser

    ash_authentication_live_session :default,
      layout: {CanaryWeb.Layouts, :app},
      on_mount: [
        {CanaryWeb.LiveUserAuth, :live_user_required},
        CanaryWeb.NavLive
      ] do
      live "/", CanaryWeb.HomeLive, :none
      live "/editor", CanaryWeb.EditorLive, :none
      live "/editor/:id", CanaryWeb.EditorLive, :none
      live "/interactions", CanaryWeb.InteractionsLive, :none
      live "/settings", CanaryWeb.SettingsLive, :none
    end
  end

  scope "/api" do
    pipe_through :api

    post "/submit", CanaryWeb.PublicApiController, :submit

    forward "/", CanaryWeb.AshRouter
  end

  if Application.compile_env(:canary, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      live_session :dev, layout: {CanaryWeb.Layouts, :dev} do
        live "/crawler", CanaryWeb.Dev.CrawlerLive, :none
        live "/reader", CanaryWeb.Dev.ReaderLive, :none
      end
    end
  end
end

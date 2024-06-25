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

  pipeline :public_api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  pipeline :private_api do
    plug :accepts, ["json"]
    plug :load_from_bearer
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
      on_mount: [
        {CanaryWeb.LiveUserAuth, :live_user_optional},
        CanaryWeb.NavLive
      ] do
      live "/", CanaryWeb.HomeLive, :none
      live "/sources", CanaryWeb.SourcesLive, :none
      live "/clients", CanaryWeb.ClientsLive, :none
      live "/sessions", CanaryWeb.SessionsLive, :none
      live "/settings", CanaryWeb.SettingsLive, :none
    end
  end

  scope "/", CanaryWeb do
    pipe_through :public_api

    post "/api/website/submit", PublicApiController, :website_submit
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:canary, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

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
    plug CanaryWeb.Plug.LoadAccountFromUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  scope "/" do
    pipe_through :browser

    live_session :auth, layout: {CanaryWeb.Layouts, :root} do
      live "/register", CanaryWeb.AuthLive.Index, :register
      live "/sign-in", CanaryWeb.AuthLive.Index, :sign_in
      live "/reset-request", CanaryWeb.AuthLive.Index, :reset_request
    end

    sign_out_route(CanaryWeb.AuthController)
    auth_routes_for(Canary.Accounts.User, to: CanaryWeb.AuthController)

    reset_route(
      live_view: CanaryWeb.AuthLive.Index,
      layout: {CanaryWeb.Layouts, :root}
    )
  end

  scope "/" do
    pipe_through :browser

    get "/checkout", CanaryWeb.CheckoutController, :session

    ash_authentication_live_session :default,
      layout: {CanaryWeb.Layouts, :app},
      on_mount: [
        {CanaryWeb.LiveUserAuth, :live_user_required},
        {CanaryWeb.LiveUserAuth, :live_ensure_account},
        CanaryWeb.NavLive
      ] do
      live "/", CanaryWeb.HomeLive, :none
      live "/source", CanaryWeb.SourceLive, :none
      live "/insights", CanaryWeb.InsightsLive, :none
      live "/settings", CanaryWeb.SettingsLive, :none
      live "/settings/subdomain", CanaryWeb.SettingsSubdomainLive, :none
    end

    ash_authentication_live_session :others,
      layout: {CanaryWeb.Layouts, :root},
      on_mount: [{CanaryWeb.LiveUserAuth, :live_user_required}] do
      live "/setup/github", CanaryWeb.GithubSetupLive, :none
      live "/onboarding", CanaryWeb.OnboardingLive, :none
    end
  end

  scope "/api/v1" do
    pipe_through :api

    post "/search", CanaryWeb.OperationsController, :search
    post "/ask", CanaryWeb.OperationsController, :ask
    post "/feedback/page", CanaryWeb.OperationsController, :feedback_page

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

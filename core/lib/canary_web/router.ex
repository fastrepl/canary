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
    plug CORSPlug, origin: &CanaryWeb.Router.origin/0
  end

  def origin() do
    Cachex.fetch!(:cache, :origin, fn ->
      {:commit, Canary.Accounts.Key.allowed_hosts!(), ttl: :timer.seconds(30)}
    end)
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

    live_session :demo, layout: {CanaryWeb.Layouts, :root} do
      live "/demo", CanaryWeb.DemoLive.Index, :without_slug
      live "/demo/:slug", CanaryWeb.DemoLive.Index, :with_slug
    end

    ash_authentication_live_session :default,
      layout: {CanaryWeb.Layouts, :app},
      on_mount: [
        {CanaryWeb.LiveUserAuth, :live_user_required},
        CanaryWeb.NavLive
      ] do
      live "/", CanaryWeb.HomeLive, :none
      live "/source", CanaryWeb.SourceLive.Index, :index
      live "/source/:id", CanaryWeb.SourceLive.Index, :detail
      live "/insights", CanaryWeb.InsightsLive, :none
      live "/settings", CanaryWeb.SettingsLive.Index, :none
    end

    ash_authentication_live_session :others,
      layout: {CanaryWeb.Layouts, :root},
      on_mount: [{CanaryWeb.LiveUserAuth, :live_user_required}] do
      live "/setup/github", CanaryWeb.GithubSetupLive, :none
    end
  end

  scope "/api/v1" do
    pipe_through :api

    post "/search", CanaryWeb.OperationsController, :search
    post "/ask", CanaryWeb.OperationsController, :ask
  end

  if Application.compile_env(:canary, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      live_session :dev, layout: {CanaryWeb.Layouts, :dev} do
        live "/reader", CanaryWeb.Dev.ReaderLive, :none
        live "/searcher", CanaryWeb.Dev.SearcherLive, :none
        live "/understander", CanaryWeb.Dev.UnderstanderLive, :none
        live "/responder", CanaryWeb.Dev.ResponderLive, :none
      end
    end
  end
end

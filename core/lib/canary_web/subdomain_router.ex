defmodule CanaryWeb.SubdomainRouter do
  use CanaryWeb, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {CanaryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :browser

    live_session :subdomain,
      layout: {CanaryWeb.Layouts, :subdomain},
      on_mount: [
        {CanaryWeb.SubdomainMountLive, :current_account}
      ] do
      live "/", CanaryWeb.SubdomainIndexLive, :none
      live "/p/:id", CanaryWeb.SubdomainPostLive, :none
    end
  end
end

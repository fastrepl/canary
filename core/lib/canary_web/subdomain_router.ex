defmodule CanaryWeb.SubdomainRouter do
  use CanaryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
  end

  scope "/" do
    pipe_through :browser

    get "/embed", CanaryWeb.ExperimentalController, :embed
  end
end

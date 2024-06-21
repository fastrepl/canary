defmodule Canary.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CanaryWeb.Telemetry,
      Canary.Repo,
      {Oban, Application.fetch_env!(:canary, Oban)},
      {DNSCluster, query: Application.get_env(:canary, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Canary.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Canary.Finch},
      # Start a worker by calling: Canary.Worker.start_link(arg)
      # {Canary.Worker, arg},
      # Start to serve requests, typically the last entry
      CanaryWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Canary.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CanaryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

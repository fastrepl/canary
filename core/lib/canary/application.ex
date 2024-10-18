defmodule Canary.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    add_sentry_logger()
    attach_oban_telemetry()

    :ok = OpentelemetryPhoenix.setup()
    :ok = Oban.Telemetry.attach_default_logger()

    :ok =
      OpentelemetryEcto.setup(
        [:canary, :repo],
        db_statement: :enabled,
        time_unit: :millisecond
      )

    children =
      [
        Canary.Insights.Processor,
        Canary.Vault,
        {Cachex, name: :cache},
        {Task.Supervisor, name: Canary.TaskSupervisor},
        {AshAuthentication.Supervisor, otp_app: :canary},
        CanaryWeb.Telemetry,
        Canary.Repo,
        {Oban, Application.fetch_env!(:canary, Oban)},
        {DNSCluster, query: Application.get_env(:canary, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Canary.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: Canary.Finch}
      ] ++ discord() ++ stripe() ++ [CanaryWeb.Endpoint]

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

  defp discord() do
    if Application.get_env(:nostrum, :token) do
      [Nostrum.Application, Canary.Sources.DiscordConsumer]
    else
      []
    end
  end

  defp stripe do
    if Application.get_env(:canary, :dev_routes, false) and
         Phoenix.Endpoint.server?(:canary, CanaryWeb.Endpoint) do
      [{Canary.StripeWebhookListener, [forward_to: "http://localhost:4000/webhook/stripe"]}]
    else
      []
    end
  end

  # https://hexdocs.pm/oban/Oban.Telemetry.html#module-job-events
  defp attach_oban_telemetry do
    :telemetry.attach_many(
      "oban-job-events",
      [
        [:oban, :job, :start],
        [:oban, :job, :stop],
        [:oban, :job, :exception]
      ],
      &Canary.Workers.JobReporter.handle_job/4,
      nil
    )
  end

  defp add_sentry_logger() do
    :logger.add_handler(:sentry_handler, Sentry.LoggerHandler, %{
      config: %{metadata: [:file, :line]}
    })
  end
end

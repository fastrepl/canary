# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :canary,
  ecto_repos: [Canary.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :canary, CanaryWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CanaryWeb.ErrorHTML, json: CanaryWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Canary.PubSub,
  live_view: [signing_salt: "j9Bh8pkL"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :canary, Canary.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  canary: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  canary: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :canary, :env, Mix.env()
config :canary, :root, File.cwd!()

config :canary, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10, embedder: 10, fetcher: 10, pruner: 5],
  repo: Canary.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(5)},
    {Oban.Plugins.Cron,
     crontab: [
       {"0 0 * * *", Canary.Workers.Updater, queue: :default}
     ]}
  ]

config :canary, Canary.Repo, types: Canary.PostgrexTypes

config :canary,
  ash_domains: [
    Canary.Accounts,
    Canary.Sources,
    Canary.Clients,
    Canary.Sessions
  ]

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

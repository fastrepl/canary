import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/canary start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :canary, CanaryWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 =
    if System.get_env("ECTO_IPV6") in ~w(true 1),
      do: [:inet6],
      else: []

  maybe_ssl =
    if System.get_env("ECTO_SSL") in ~w(true 1),
      do: [cacerts: :public_key.cacerts_get()],
      else: false

  config :canary, Canary.Repo,
    url: database_url,
    timeout: String.to_integer(System.get_env("DATABASE_TIMEOUT") || "15000"),
    pool_size: String.to_integer(System.get_env("DATABASE_POOL_SIZE") || "10"),
    socket_options: maybe_ipv6,
    ssl: maybe_ssl

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :canary, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :canary, CanaryWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :canary, CanaryWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :canary, CanaryWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  config :canary, Canary.Mailer,
    adapter: Resend.Swoosh.Adapter,
    api_key: System.get_env("RESEND_API_KEY")

  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end

config :nostrum, :token, System.get_env("DISCORD_BOT_TOKEN")

config :canary, :discord_webhook_url, System.get_env("DISCORD_WEBHOOK_URL")

config :canary, :openai_api_base, System.get_env("OPENAI_API_BASE")
config :canary, :openai_api_key, System.get_env("OPENAI_API_KEY")

config :canary, :responder_model, System.get_env("RESPONDER_MODEL")
config :canary, :general_model, System.get_env("GENERAL_MODEL")

if config_env() != :test do
  if System.get_env("GITHUB_CLIENT_ID") && System.get_env("GITHUB_CLIENT_SECRET") do
    config :oapi_github,
      app_name: "getcanary.dev",
      default_auth: {System.get_env("GITHUB_CLIENT_ID"), System.get_env("GITHUB_CLIENT_SECRET")}
  else
    config :oapi_github, app_name: "getcanary.dev"
  end

  if [
       "STRIPE_SECRET_KEY",
       "STRIPE_PUBLIC_KEY",
       "STRIPE_CUSTOMER_PORTAL_URL",
       "STRIPE_WEBHOOK_SECRET",
       "STRIPE_STARTER_PRICE"
     ]
     |> Enum.any?(&System.get_env/1) do
    config :stripity_stripe, api_key: System.get_env("STRIPE_SECRET_KEY")

    config :canary, :stripe_secret_key, System.fetch_env!("STRIPE_SECRET_KEY")
    config :canary, :stripe_public_key, System.fetch_env!("STRIPE_PUBLIC_KEY")
    config :canary, :stripe_customer_portal_url, System.fetch_env!("STRIPE_CUSTOMER_PORTAL_URL")
    config :canary, :stripe_webhook_secret, System.fetch_env!("STRIPE_WEBHOOK_SECRET")
    config :canary, :stripe_starter_price_id, System.fetch_env!("STRIPE_STARTER_PRICE")
  end

  config :canary, :trieve_api_key, System.get_env("TRIEVE_API_KEY")
  config :canary, :trieve_dataset, System.get_env("TRIEVE_DATASET")
end

config :canary, :master_user_email, System.get_env("MASTER_USER_EMAIL")

config :canary, :clone_dir, System.get_env("REPO_DIR", "./tmp")

config :canary, :tinybird,
  api_key: System.get_env("TINYBIRD_API_KEY"),
  base_url: System.get_env("TINYBIRD_BASE_URL")

config :canary, :github,
  enabled?: System.get_env("GITHUB_CLIENT_ID") != nil,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: System.get_env("GITHUB_REDIRECT_URI")

config :canary, :self_host, System.get_env("SELF_HOST") in ~w(true 1)

config :canary, :fly_api_key, System.get_env("FLY_API_KEY")
config :canary, :fly_app_name, System.get_env("FLY_APP_NAME")

if config_env() == :prod do
  if [
       "OTEL_COLLECTOR_URL",
       "OTEL_COLLECTOR_URL_AUTH"
     ]
     |> Enum.any?(&System.get_env/1) do
    config :opentelemetry_exporter,
      otlp_protocol: :http_protobuf,
      otlp_endpoint: System.fetch_env!("OTEL_COLLECTOR_URL"),
      otlp_headers: [{"Authorization", "Bearer #{System.fetch_env!("OTEL_COLLECTOR_URL_AUTH")}"}]
  end
end

if System.get_env("SELF_HOST") not in ~w(true 1) do
  if [
       "PUPPETEER_BASE_URL",
       "PUPPETEER_API_KEY"
     ]
     |> Enum.any?(&System.get_env/1) do
    config :canary, :puppeteer,
      base_url: System.get_env("PUPPETEER_BASE_URL"),
      api_key: System.get_env("PUPPETEER_API_KEY")
  end
end

defmodule CanaryWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :canary

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_canary_key",
    signing_salt: "fDHL5Tcf",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :canary,
    gzip: false,
    only: CanaryWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :canary
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug CanaryWeb.GithubWebhookPlug,
    at: "/webhook/github",
    handler: CanaryWeb.GithubWebhookHandler

  plug Stripe.WebhookPlug,
    at: "/webhook/stripe",
    handler: CanaryWeb.StripeWebhookHandler,
    secret: "whsec_4b43f33c1f5330c12013c5d3dc06076f00247b4b32ec9400cc09033289a817e3"

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug CanaryWeb.Router
end

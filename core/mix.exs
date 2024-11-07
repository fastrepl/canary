defmodule Canary.MixProject do
  use Mix.Project

  def project do
    [
      app: :canary,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      consolidate_protocols: Mix.env() == :prod,
      releases: [
        canary: [
          applications: [
            opentelemetry_exporter: :permanent,
            opentelemetry: :temporary
          ]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Canary.Application, []},
      extra_applications: [:logger, :runtime_tools],
      included_applications: [:nostrum]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0-rc.7", override: true},
      {:floki, ">= 0.30.0"},
      {:html5ever, "~> 0.16.0"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.25"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:oban, "~> 2.17"},
      {:rustler, "~> 0.34.0"},
      {:nostrum, "~> 0.8.0", runtime: false},
      {:gun, "~> 2.0"},
      {:ash, "~> 3.4"},
      {:ash_phoenix, "== 2.1.4"},
      {:ash_authentication, "~> 4.0"},
      {:ash_authentication_phoenix, "~> 2.1"},
      {:ash_postgres, "~> 2.3"},
      {:open_api_spex, "~> 3.21"},
      {:picosat_elixir, "~> 0.2.3"},
      {:req, "~> 0.5.0"},
      {:retry, "~> 0.18"},
      {:mox, "~> 1.0", only: :test},
      {:req_crawl, "~> 0.2.0"},
      {:saxy, "~> 1.5"},
      {:hammer, "~> 6.0"},
      {:live_svelte, "~> 0.13.3"},
      {:stripity_stripe, "~> 3.2"},
      {:oapi_github, "~> 0.3.3"},
      {:httpoison, "~> 2.2"},
      {:resend, "~> 0.4.2"},
      {:cachex, "~> 4.0"},
      {:bumblebee, "~> 0.5.3"},
      {:absinthe_client, "~> 0.1.0"},
      {:cloak, "~> 1.1"},
      {:ash_cloak, "~> 0.1.2"},
      {:primer_live, "~> 0.8"},
      {:hop, "~> 0.1"},
      {:ex_json_schema, "~> 0.10"},
      {:yaml_elixir, "~> 2.11"},
      {:sentry, "~> 10.7.0"},
      {:hackney, "~> 1.8"},
      {:opentelemetry_exporter, "~> 1.7"},
      {:opentelemetry, "1.4.0"},
      {:opentelemetry_api, "1.3.1"},
      {:opentelemetry_req, "~> 0.2.0"},
      {:opentelemetry_ecto, "~> 1.2"},
      {:opentelemetry_phoenix, "~> 1.2"},
      {:corsica, "~> 2.0"},
      {:ex2ms, "~> 1.7"},
      {:recon, "~> 2.5", override: true},
      {:recon_ex,
       github: "tatsuya6502/recon_ex", ref: "0ce4c5da777937a5bb57d3e68b9afcb9877c1c3b"},
      {:live_toast, "~> 0.6.4"},
      {:flow, "~> 1.0"},
      {:number, "~> 1.0.1"},
      {:earmark, "~> 1.4"}
    ] ++ deps_eval()
  end

  defp deps_eval() do
    [
      {:progress_bar, "~> 3.0"},
      {:ymlr, "~> 5.0", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd --cd assets npm install"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind canary", "esbuild canary"],
      "assets.deploy": [
        "tailwind canary --minify",
        "cmd --cd assets node build.js --deploy",
        "phx.digest"
      ],
      "ash.clean": [
        "ash_postgres.squash_snapshots",
        "cmd npx prettier priv/resource_snapshots -w"
      ]
    ]
  end
end

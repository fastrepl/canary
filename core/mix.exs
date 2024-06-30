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
      deps: deps()
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
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:floki, ">= 0.30.0"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
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
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},
      {:oban, "~> 2.17"},
      {:rustler, "~> 0.32.1"},
      {:nostrum, "~> 0.9.1", runtime: false},
      {:gun, "~> 2.0"},
      {:ash, "~> 3.0", consolidate_protocols: Mix.env() == :prod},
      {:ash_authentication, "~> 4.0"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_json_api, "~> 1.0"},
      {:open_api_spex, "~> 3.16"},
      {:picosat_elixir, "~> 0.2.3"},
      {:req, "~> 0.5.0"},
      {:retry, "~> 0.18"},
      {:cors_plug, "~> 3.0"},
      {:mox, "~> 1.0", only: :test},
      {:crawler,
       git: "https://github.com/fredwu/crawler.git",
       ref: "6866bbe287c760b7e4bba1925e80f2a4494d7af3"},
      {:oapi_github, "~> 0.3.3"},
      {:req_crawl, "~> 0.2.0"},
      {:saxy, "~> 1.5"},
      {:hammer, "~> 6.0"},
      {:opentelemetry_exporter, "~> 1.2"},
      {:opentelemetry, "~> 1.2"},
      {:opentelemetry_api, "~> 1.2"},
      {:opentelemetry_req, "~> 0.2.0"},
      {:abstracing, git: "https://github.com/msramos/abstracing.git", branch: "main"}
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
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind canary", "esbuild canary"],
      "assets.deploy": [
        "tailwind canary --minify",
        "esbuild canary --minify",
        "phx.digest"
      ]
    ]
  end
end

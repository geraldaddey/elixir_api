defmodule acme.MixProject do
  use Mix.Project

  def project do
    [
			app: :acme,
			version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
				prod: [
					include_executables_for: [:unix],
					applications: [runtime_tools: :permanent],
          overlays: ["envs/"]
				],
				dev: [
					include_executables_for: [:unix],
					applications: [runtime_tools: :permanent],
          overlays: ["envs/"]
				]
			]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:corsica, :logger, :eex, :pdf_generator],
      extra_applications: [:logger, :cowboy, :plug, :poison, :ecto, :postgrex, :httpoison, :sweet_xml, :timex, :quantum, :comeonin, :bcrypt_elixir, :plug_cowboy, :cloak, :cors_plug, :cors_plug, :pigeon, :kadabra, :bamboo, :bamboo_smtp, :geoip, :phone, :countries, :corsica, :cloudex, :jason, :remote_ip],
      mod: {acme.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.8"},
      {:plug, "~> 1.10"},
      {:poison, "~> 4.0"},
      {:ecto, "~> 3.4"},
      {:postgrex, "~> 0.15.5"},
      {:httpoison, "~> 1.7"},
      {:sweet_xml, "~> 0.6.6"},
      {:quantum, "~> 3.1"},
      {:timex, "~> 3.6"},
      {:comeonin, "~> 5.3"},
      {:bcrypt_elixir, "~> 2.0"},
      {:cloak, "~> 1.0"},
      {:cloak_ecto, "~> 1.0.1"},
      {:cors_plug, "~> 2.0"},
      {:plug_cowboy, "~> 2.3"},
      {:pigeon, "~> 1.5"},
      {:kadabra, "~> 0.4.5"},
      {:bamboo, "~> 1.5"},
      {:bamboo_smtp, "~> 2.1"},
      {:geoip, "~> 0.2.3"},
      {:corsica, "~> 1.0"},
      {:cloudex, "~> 1.4"},
      {:remote_ip, "~> 0.2.1"},
      {:sendgrid, "~> 2.0"},
      {:decimal, "~> 1.8"},
      {:ecto_sql, "~> 3.4"},
      {:phone, "~> 0.4.5"},
      {:countries, "~> 1.5"},
      {:jason, "~> 1.0"},
      {:pdf_generator, "~> 0.6.2"},
      {:sneeze, "~> 1.2"},
      {:distillery, "~> 2.0"},
      {:dotenvy, "~> 0.8.0"}
    ]
  end
end

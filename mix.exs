defmodule Proxy.MixProject do
  use Mix.Project

  def project do
    [
      releases: [
        proxy_dev: [
          include_executables_for: [:windows],
          applications: [runtime_tools: :permanent]
        ]
      ],
      app: :proxy,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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
      mod: {Proxy.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix, "~> 1.4.15"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 3.2"},
      {:ecto, "~> 2.2.0"},
      {:tds_ecto, "~> 2.2.0"},
      #{:ecto_sql, "~> 3.1"},
      #{:postgrex, ">= 0.0.0"},
      {:tds, "~> 1.1.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:timex, "~> 3.6"},
      {:httpoison, "~> 0.13.0"},
      {:poison, "~> 3.1"},
      {:calendar, "~> 0.17.0"},
      {:bamboo, "~> 1.3"},
      {:bamboo_smtp, "~> 2.1.0"},
      {:number, "~> 0.5.7"},
      {:date_time_parser, "~> 0.2.0"},
      {:xlsxir, "~> 1.6.2"},
      {:csv, "~> 2.0.0"},
      {:quantum, "~> 2.2.7"},
      {:logger_file_backend, "~> 0.0.10"},
      {:skooma, "~> 0.2.0"},
      {:cachex, "~> 3.2"},
      {:scrivener, "~> 2.0"},
      {:sweet_xml, "~> 0.6.6"},
      {:scrivener_ecto, "~> 1.0"}
    ]
  end



  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

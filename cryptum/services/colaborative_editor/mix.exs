defmodule ColaborativeEditor.MixProject do
  use Mix.Project

  def project do
    [
      app: :colaborative_editor,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ColaborativeEditor.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.6.3"},
      {:phoenix_html, "~> 4.2.1"},
      {:phoenix_html_helpers, "~> 1.0.1"},
      {:phoenix_live_reload, "~> 1.6.0", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8.6"},
      {:phoenix_view, "~> 2.0.4"},
      {:phoenix_live_view, "~> 1.0.10"},
      {:telemetry_metrics, "~> 1.1.0"},
      {:telemetry_poller, "~> 1.2.0"},
      {:gettext, "~> 0.26.2"},
      {:jason, "~> 1.4.4"},
      {:plug_cowboy, "~> 2.7.3"},
      {:dotenvy, "~> 1.1.0"},
      {:httpoison, "~> 2.2.3"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd yarn install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end

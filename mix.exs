defmodule FinancialSystem.MixProject do
  use Mix.Project

  def project do
    [
      app: :financial_system,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),

      # Docs
      name: "Financial System",
      source_url: "https://github.com/maikkkko1/elixir-financial-system",
      homepage_url: "https://github.com/maikkkko1/elixir-financial-system",
      docs: [
        # The main page in the docs
        main: "api-reference",
        extras: ["README.md"]
      ]
    ]
  end

  # Ensures `test/support/*.ex` files are read during tests
  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      # Ensures database is reset before tests are run
      test: ["ecto.create --quiet", "ecto.migrate", "test", "ecto.drop --quiet"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :sqlite_ecto2, :ecto],
      mod: {FinancialSystem.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sqlite_ecto2, "~> 2.2"},
      {:hackney, "~> 1.15.2"},
      {:jason, ">= 1.0.0"},
      {:tesla, "~> 1.3.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:cowboy, "~> 2.4"},
      {:poison, "~> 3.1"},
      {:plug, "~> 1.6"},
      {:plug_cowboy, "~> 2.0"},
      {:money, "~> 1.4"}
    ]
  end
end

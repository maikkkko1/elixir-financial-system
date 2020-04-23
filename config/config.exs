use Mix.Config

config :financial_system, FinancialSystem.Repo,
  adapter: Sqlite.Ecto2,
  database: "financial_system.sqlite3"

config :financial_system, ecto_repos: [FinancialSystem.Repo]

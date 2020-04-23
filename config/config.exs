use Mix.Config

config :financial_system, FinancialSystem.Repo,
  adapter: Sqlite.Ecto2,
  database: "financial_system.sqlite3"

config :financial_system, ecto_repos: [FinancialSystem.Repo]

config :money,
  default_currency: :BRL,
  separator: ".",
  delimiter: ",",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false,
  fractional_unit: true,
  strip_insignificant_zeros: false

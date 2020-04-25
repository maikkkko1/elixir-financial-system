use Mix.Config

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

if System.get_env("MIX_ENV") == "test" do
  config :financial_system, FinancialSystem.Repo,
    adapter: Sqlite.Ecto2,
    pool: Ecto.Adapters.SQL.Sandbox,
    timeout: 60000,
    database: "test_db.sqlite3"
else
  config :financial_system, FinancialSystem.Repo,
    adapter: Sqlite.Ecto2,
    database: "db.sqlite3"
end

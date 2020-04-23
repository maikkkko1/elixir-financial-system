defmodule FinancialSystem.Repo do
  use Ecto.Repo, otp_app: :financial_system, adapter: Sqlite.Ecto2
end

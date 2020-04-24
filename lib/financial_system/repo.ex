defmodule FinancialSystem.Repo do
  @moduledoc """
  Application Repo, handle some database operations.
  """

  use Ecto.Repo, otp_app: :financial_system, adapter: Sqlite.Ecto2
end

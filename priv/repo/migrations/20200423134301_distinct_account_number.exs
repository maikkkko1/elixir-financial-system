defmodule FinancialSystem.Repo.Migrations.DistinctAccountNumber do
  @moduledoc """
  Define a unique index for the number field in accounts table.
  """

  use Ecto.Migration

  def change do
    create(index(:accounts, [:number], unique: true))
  end
end

defmodule FinancialSystem.Repo.Migrations.CreateAccount do
  @moduledoc """
  Accounts table migration.
  """

  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:name, :string)
      add(:number, :integer)
      add(:agency, :integer)
      add(:currency, :string)
      add(:balance, :integer)
      timestamps()
    end
  end
end

defmodule FinancialSystem.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:account_number_from, :integer)
      add(:account_number_to, :integer)
      add(:amount, :float)
      timestamps()
    end
  end
end

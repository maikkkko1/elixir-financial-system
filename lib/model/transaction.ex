defmodule Transaction do
  @moduledoc """
  Transaction model.
  """

  use Ecto.Schema

  schema "transactions" do
    field(:transaction_type, :integer, null: false)
    field(:account_number_from, :integer, null: true)
    field(:account_number_to, :integer, null: true)
    field(:amount, :integer, null: false)
    timestamps()
  end
end

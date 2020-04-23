defmodule Transaction do
  @moduledoc """
  Transaction model.
  """

  use Ecto.Schema

  schema "transactions" do
    field(:account_number_from, :integer, null: false)
    field(:account_number_to, :integer, null: false)
    field(:amount, :float, null: false)
    timestamps()
  end
end

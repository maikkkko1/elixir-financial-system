defmodule Account do
  @moduledoc """
  Account model.
  """

  use Ecto.Schema

  schema "accounts" do
    field(:name, :string, null: false)
    field(:number, :integer, null: false)
    field(:agency, :integer, null: false)
    field(:currency, :string, default: "BRL")
    field(:balance, :integer, default: 0)
    timestamps()
  end
end

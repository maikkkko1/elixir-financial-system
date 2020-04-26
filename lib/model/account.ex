defmodule Account do
  @moduledoc """
  Account model.
  """

  use Ecto.Schema

  @derive {Poison.Encoder,
           only: [:id, :name, :number, :agency, :currency, :balance, :inserted_at, :updated_at]}

  schema "accounts" do
    field(:name, :string, null: false)
    field(:number, :integer, null: false)
    field(:agency, :integer, null: false)
    field(:currency, :string, default: "BRL")
    field(:balance, :integer)
    timestamps()
  end
end

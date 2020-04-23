defmodule AccountService do
  @moduledoc """
  Account service, handle the account logic operations.
  """

  def create_account(name, number, agency \\ 0, currency \\ "BRL", balance \\ 0) do
    cond do
      !Util.is_valid_string?(name) ->
        {:error, "Invalid name!"}

      !is_integer(number) ->
        {:error, "Invalid number!"}

      !is_integer(agency) ->
        {:error, "Invalid agency!"}

      !is_number(balance) ->
        {:error, "Invalid balance!"}

      true ->
        "true"
    end
  end
end

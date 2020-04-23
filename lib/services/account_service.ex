defmodule AccountService do
  @moduledoc """
  Account service, handle the account logic operations.
  """

  alias FinancialSystem.Repo, as: DB

  import Ecto.Query

  @spec create_account(String.t(), integer, integer, String.t(), float) ::
          {:error, String.t()} | {:ok, Account}
  def create_account(name, number, agency \\ 0, currency \\ "BRL", balance \\ 0.0) do
    validate_params = validate_create_params?(name, number, agency, currency, balance)

    case validate_params do
      {:error, _error} ->
        validate_params

      {:ok, _ok} ->
        exists = get_account_by_number(number)

        if !exists do
          account = %Account{
            name: name,
            number: number,
            agency: agency,
            currency: String.upcase(currency),
            balance: balance
          }

          {:ok, DB.insert(account)}
        else
          {:error, "Account number already exists!"}
        end
    end
  end

  @spec get_account_by_number(integer) :: boolean | Account
  def get_account_by_number(account_number) do
    if !is_integer(account_number), do: false

    DB.one(
      Account
      |> select([account], account)
      |> where([account], account.number == ^account_number)
    )
  end

  @spec get_account_by_id(integer) :: boolean | Account
  def get_account_by_id(account_id) do
    if !is_integer(account_id), do: false

    DB.one(
      Account
      |> select([account], account)
      |> where([account], account.id == ^account_id)
    )
  end

  @spec get_all_accounts :: [Account]
  def get_all_accounts do
    DB.all(
      Account
      |> select([account], account)
    )
  end

  def update_account_by_id(id, data) do
    changes = Ecto.Changeset.cast(%Account{id: id}, data, [:name, :agency, :currency])

    update = DB.update(changes)

    case update do
      {:error, _error} ->
        {:error, "Failed to update account!"}

      {:ok, _account} ->
        get_account_by_id(id)
    end
  end

  defp validate_create_params?(name, number, agency, currency, balance) do
    cond do
      !Util.is_valid_string?(name) ->
        {:error, "Invalid name! Must be a string value!"}

      !CurrencyService.is_valid_currency?(currency) ->
        {:error, "Invalid currency!"}

      !is_integer(number) ->
        {:error, "Invalid number! Must be a integer value!"}

      !is_integer(agency) ->
        {:error, "Invalid agency! Must be a integer value!"}

      !is_float(balance) ->
        {:error, "Invalid balance! Must be a float value!"}

      true ->
        {:ok, true}
    end
  end
end

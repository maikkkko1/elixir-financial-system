defmodule AccountService do
  @moduledoc """
  Account service, handle account logic operations.
  """

  alias FinancialSystem.Repo, as: DB

  import Ecto.Query

  @doc """
  Creates a new account.

  ## Parameters

    - name: String that represents the account holder name.
    - number: Integer that represents the account number. UNIQUE
    - agency: Integer that represents the account agency number.
    - currency - String that represents the account main currency.
    - balance - Float that represents the account initial balance.

  ## Examples

      iex> AccountService.create_account("Maikon", 12345, 1111, "brl", 100.0)

  """
  @spec create_account(String.t(), integer, integer, String.t(), integer) ::
          {:error, String.t()} | {:ok, Account}
  def create_account(name, number, agency \\ 0, currency \\ "BRL", balance \\ 0) do
    validate_params = validate_create_params(name, number, agency, currency, balance)

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

          DB.insert(account)
        else
          {:error, "Account number already exists!"}
        end
    end
  end

  @doc """
  Return the account balance.

  ## Parameters

    - account_number: Integer that represents the account number.
    - format: Boolean that represents if the balance will be formatted or not. DEFAULT FALSE - Ex: formatted = "10,00" | unformatted = 1000

  ## Examples

      iex> AccountService.get_account_balance_by_number(2)
      {:ok, 3000}

      iex> AccountService.get_account_balance_by_number(2, true)
      {:ok, "30,00"}

  """
  @spec get_account_balance_by_number(integer, boolean) ::
          {:error, String.t()} | {:ok, integer | String.t()}
  def get_account_balance_by_number(account_number, format \\ false) do
    if !is_integer(account_number), do: false

    balance =
      DB.one(
        Account
        |> select([account], account.balance)
        |> where([account], account.number == ^account_number)
      )

    if balance != nil do
      format_balance = if format, do: Money.new(balance) |> to_string, else: balance

      {:ok, format_balance}
    else
      {:error, "Account not found"}
    end
  end

  @doc """
  Return the account record from database by the account number.

  ## Parameters

    - account_number: Integer that represents the account number.

  ## Examples

      iex> AccountService.get_account_by_number(2)
      %Account{
        __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
        agency: 1,
        balance: 3000...
      }

  """
  @spec get_account_by_number(integer) :: boolean | Account | nil
  def get_account_by_number(account_number) do
    if !is_integer(account_number), do: false

    DB.one(
      Account
      |> select([account], account)
      |> where([account], account.number == ^account_number)
    )
  end

  @doc """
  Return the account record from database by the account id.

  ## Parameters

    - account_id: Integer that represents the account id (Database Primary Key).

  ## Examples

      iex> AccountService.get_account_by_id(2)
      %Account{
        __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
        agency: 1,
        balance: 3000...
      }

  """
  @spec get_account_by_id(integer) :: false | Account | nil
  def get_account_by_id(account_id) do
    if !is_integer(account_id), do: false

    DB.one(
      Account
      |> select([account], account)
      |> where([account], account.id == ^account_id)
    )
  end

  @doc """
  Return all accounts records from database.

  """
  @spec get_all_accounts :: [Account] | []
  def get_all_accounts do
    DB.all(
      Account
      |> select([account], account)
    )
  end

  @doc """
  Update a account record in the database by the account id.

  ## Parameters

  - id: Integer that represents the account id (Database Primary Key).
  - data: Struct with the new data to be updated. Ex: %{name: "New name", currency: "USD"}

  ## Examples

    iex> AccountService.update_account_by_id(2, %{name: "New name", currency: "USD"})
    %Account{
      __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
      agency: 1,
      balance: 3000,
      name: "New name",
      currency: "USD"...
    }
  """
  @spec update_account_by_id(integer, %{}) ::
          {:error, String.t()} | {:ok, Account}
  def update_account_by_id(id, data) do
    changes = Ecto.Changeset.cast(%Account{id: id}, data, [:name, :agency, :currency, :balance])

    update = DB.update(changes)

    case update do
      {:error, _error} ->
        {:error, "Failed to update account!"}

      {:ok, _account} ->
        get_account_by_id(id)
    end
  end

  defp validate_create_params(name, number, agency, currency, balance) do
    cond do
      !Util.is_valid_string?(name) ->
        {:error, "Invalid name! Must be a string value!"}

      !CurrencyService.is_valid_currency?(currency) ->
        {:error, "Invalid currency!"}

      !is_integer(number) ->
        {:error, "Invalid account number! Must be a integer value!"}

      !is_integer(agency) ->
        {:error, "Invalid agency! Must be a integer value!"}

      !is_integer(balance) ->
        {:error, "Invalid balance! Must be a integer value!"}

      balance < 0 ->
        {:error, "Invalid balance! Must be bigger or equal 0!"}

      true ->
        {:ok, true}
    end
  end
end

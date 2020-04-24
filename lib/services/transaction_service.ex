defmodule TransactionService do
  @moduledoc """
  Transaction service, handle transactions logic operations.
  """

  # Transaction types.
  @transaction_deposit 1
  @transaction_transfer 2
  @transaction_split 3
  @transaction_withdraw 4

  alias FinancialSystem.Repo, as: DB

  import Ecto.Query
  require Logger

  def deposit(account_number, currency, amount) do
    validate_params = validate_transaction_params(account_number, currency, amount)

    case validate_params do
      {:error, _error} ->
        validate_params

      {:ok, _ok} ->
        account = AccountService.get_account_by_number(account_number)

        if account do
          converted_amount = handle_currency_exchange(currency, account.currency, amount)

          create_transaction(@transaction_deposit, nil, account_number, converted_amount)

          account_new_balance = account.balance + converted_amount

          update_balance =
            AccountService.update_account_by_id(account.id, %{balance: account_new_balance})

          {:ok, update_balance}
        else
          {:error, "Account not found!"}
        end
    end
  end

  def withdraw(account_number, currency, amount) do
    validate_params = validate_transaction_params(account_number, currency, amount)

    case validate_params do
      {:error, _error} ->
        validate_params

      {:ok, _ok} ->
        account = AccountService.get_account_by_number(account_number)

        cond do
          !account ->
            {:error, "Account not found!"}

          !has_funds?(account.balance, account.currency, amount, currency) ->
            {:error, "Insufficient funds!"}

          true ->
            converted_amount = handle_currency_exchange(currency, account.currency, amount)

            create_transaction(@transaction_withdraw, account_number, nil, converted_amount)

            account_new_balance = account.balance - converted_amount

            update_balance =
              AccountService.update_account_by_id(account.id, %{balance: account_new_balance})

            {:ok, update_balance}
        end
    end
  end

  def transfer(account_number_from, account_number_to, amount) do
    validate_params = validate_transfer_params(account_number_from, account_number_to, amount)

    case validate_params do
      {:error, _error} ->
        validate_params

      {:ok, _ok} ->
        account_from = AccountService.get_account_by_number(account_number_from)
        account_to = AccountService.get_account_by_number(account_number_to)

        cond do
          !account_from ->
            {:error, "Account from not found!"}

          !account_to ->
            {:error, "Account to not found!"}

          !has_funds?(account_from.balance, account_from.currency, amount, account_to.currency) ->
            {:error, "Insufficient funds!"}

          true ->
            converted_amount =
              handle_currency_exchange(account_to.currency, account_from.currency, amount)

            create_transaction(
              @transaction_transfer,
              account_from.number,
              account_to.number,
              converted_amount
            )

            withdraw(account_from.number, account_from.currency, converted_amount)

            deposit(account_to.number, account_to.currency, converted_amount)

            {:ok, true}
        end
    end
  end

  def has_funds?(balance, account_currency, amount, currency) do
    converted_amount = handle_currency_exchange(currency, account_currency, amount)

    balance >= converted_amount
  end

  def get_all_transactions do
    DB.all(
      Transaction
      |> select([transaction], transaction)
    )
  end

  @spec handle_currency_exchange(binary, any, any) :: any
  defp handle_currency_exchange(currency, account_currency, amount) do
    if String.upcase(currency) == account_currency do
      amount
    else
      {:ok, result} =
        CurrencyService.handle_conversion(
          currency,
          account_currency,
          Money.new(amount) |> to_string
        )

      result.amount_converted
      |> Float.to_string(decimals: 2)
      |> String.replace(".", "")
      |> String.to_integer()
    end
  end

  defp create_transaction(type, account_from, account_to, amount) do
    cond do
      !is_integer(type) ->
        {:error, "Invalid transaction type!"}

      true ->
        transaction = %Transaction{
          transaction_type: type,
          account_number_from: account_from,
          account_number_to: account_to,
          amount: amount
        }

        DB.insert(transaction)
    end
  end

  defp validate_transaction_params(number, currency, amount) do
    cond do
      !CurrencyService.is_valid_currency?(currency) ->
        {:error, "Invalid currency!"}

      !is_integer(number) ->
        {:error, "Invalid account number! Must be a integer value!"}

      !is_integer(amount) ->
        {:error, "Invalid amount! Must be a integer value!"}

      amount <= 0 ->
        {:error, "Invalid amount! Must be bigger than 0!"}

      true ->
        {:ok, true}
    end
  end

  defp validate_transfer_params(account_number_from, account_number_to, amount) do
    cond do
      !is_integer(account_number_from) ->
        {:error, "Invalid account number from! Must be a integer value!"}

      !is_integer(account_number_to) ->
        {:error, "Invalid account number to! Must be a integer value!"}

      !is_integer(amount) ->
        {:error, "Invalid amount! Must be a integer value!"}

      amount <= 0 ->
        {:error, "Invalid amount! Must be bigger than 0!"}

      true ->
        {:ok, true}
    end
  end
end

defmodule TransactionService do
  @moduledoc """
  Transaction service, handle transactions logic operations.
  """

  # Transaction types.
  @transaction_deposit 1
  @transaction_transfer 2
  @transaction_withdraw 3

  alias FinancialSystem.Repo, as: DB

  import Ecto.Query

  @doc """
  Make a new deposit in the indicated account.

  ## Parameters

    - account_number: Integer that represents the account number to deposit.
    - currency - String that represents the deposit currency. Ex: "brl", "usd", "eur"
    - amount: Integer that represents the amount to deposit. Ex: 100 = 1,00 | 1000 = 10,00 | 5050 = 50,50

  ## Examples

      iex> TransactionService.deposit(1, "brl", 1000) # Depositing in account number 1, with the currency BRL, amount of 10,00.
      iex> TransactionService.deposit(1, "usd", 1000) # If the account currency is BRL, before make the deposit will exchange 10,00 USD to BRL.
      iex> TransactionService.deposit(1, "brl", 2050) # Depositing in account number 1, with the currency BRL, amount of 20,50.

  """
  @spec deposit(integer, String.t(), integer) ::
          {:error, String.t()} | {:ok, Account | String.t()}
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

          updated_account =
            AccountService.update_account_by_id(account.id, %{balance: account_new_balance})

          {:ok, updated_account}
        else
          {:error, "Account not found!"}
        end
    end
  end

  @doc """
  If the account has sufficient funds, make a new withdraw in the indicated account.

  ## Parameters

    - account_number: Integer that represents the account number to withdraw.
    - currency - String that represents the withdraw currency. Ex: "brl", "usd", "eur"
    - amount: Integer that represents the amount to withdraw. Ex: 100 = 1,00 | 1000 = 10,00 | 5050 = 50,50

  ## Examples

      iex> TransactionService.withdraw(1, "brl", 1000) # Withdrawing in account number 1, with the currency BRL, amount of 10,00.
      iex> TransactionService.withdraw(1, "usd", 1000) # If the account currency is BRL, before make the withdraw will exchange 10,00 USD to BRL.
      iex> TransactionService.withdraw(1, "brl", 2050) # Withdrawing in account number 1, with the currency BRL, amount of 20,50.

  """
  @spec withdraw(integer, String.t(), integer) ::
          {:error, String.t()} | {:ok, Account | String.t()}
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

            updated_account =
              AccountService.update_account_by_id(account.id, %{balance: account_new_balance})

            {:ok, updated_account}
        end
    end
  end

  @doc """
  If the account has sufficient funds even with currency exchange, make a new transfer to the indicated account.

  ## Parameters

    - account_number_from: Integer that represents the account number to transfer from.
    - account_number_to - Integer that represents the account number to transfer to.
    - amount: Integer that represents the amount to transfer. Ex: 100 = 1,00 | 1000 = 10,00 | 5050 = 50,50

  ## Examples

      TransactionService.transfer(1, 2 1000) # Transfering from account number 1 to account number 2 the amount of 10,00.
      TransactionService.transfer(1, 2, 2050) # Transfering from account number 1 to account number 2 the amount of 20,50.

  """
  @spec transfer(integer, integer, integer) ::
          {:error, String.t()}
          | {:ok, %{account_from_new_balance: String.t(), account_to_new_balance: String.t()}}
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
              handle_currency_exchange(account_from.currency, account_to.currency, amount)

            create_transaction(
              @transaction_transfer,
              account_from.number,
              account_to.number,
              converted_amount
            )

            withdraw(account_from.number, account_from.currency, amount)

            deposit(account_to.number, account_to.currency, converted_amount)

            get_accounts_new_balance(account_from.number, account_to.number)
        end
    end
  end

  @doc """
  Split a transaction in several accounts.

  ## Parameters

    - split_details: List that represents the accounts and percentages to split the transaction.
    - total_amount: Integer that represents the total amount to split. Ex: 100 = 1,00 | 1000 = 10,00 | 5050 = 50,50

  ## Examples
    # Spliting between account number 1 and account number 2 the total amount of 20,00.
      iex> TransactionService.split([%{account_number: 2, percentage: 75}, %{account_number: 3, percentage: 25}], 2000)

  """
  @spec split(list, integer) :: {:error, String.t()} | {:ok, true}
  def split(split_details, total_amount) do
    validate_params = validate_split_params(split_details, total_amount)

    case validate_params do
      {:error, _error} ->
        validate_params

      {:ok, _ok} ->
        validate_percentage = valid_split_percentage?(split_details)

        validate_split_accounts = valid_split_accounts?(split_details)

        cond do
          !validate_percentage ->
            {:error,
             "Invalid split percentage in accounts! The sum of all percentages must be 100."}

          validate_split_accounts !== true ->
            {:error, validate_split_accounts}

          true ->
            execute_split(split_details, total_amount)

            {:ok, true}
        end
    end
  end

  @doc """
  Return all transactions.

  """
  @spec get_all_transactions :: [Transaction]
  def get_all_transactions do
    DB.all(
      Transaction
      |> select([transaction], transaction)
    )
  end

  defp execute_split(split_details, total_amount) do
    Enum.each(split_details, fn detail ->
      amount_transfer = detail.percentage * total_amount / 100

      account = AccountService.get_account_by_number(detail.account_number)

      deposit(detail.account_number, account.currency, trunc(amount_transfer))
    end)
  end

  defp valid_split_percentage?(split_details) do
    total_percentage = get_total_split_percentage(split_details)

    total_percentage == 100
  end

  defp get_total_split_percentage(split_details) do
    Enum.reduce(split_details, fn x, y -> x.percentage + y.percentage end)
  end

  defp valid_split_accounts?(split_details) do
    valid_accounts =
      Enum.reduce_while(split_details, [], fn el, _acc ->
        account = AccountService.get_account_by_number(el.account_number)

        case account do
          nil ->
            {:halt, "Account #{el.account_number} not found!"}

          false ->
            {:halt, "Account #{el.account_number} not found!"}

          _ ->
            {:cont, true}
        end
      end)

    valid_accounts
  end

  defp has_funds?(balance, account_currency, amount, currency) do
    converted_amount = handle_currency_exchange(currency, account_currency, amount)

    balance >= converted_amount
  end

  defp get_accounts_new_balance(account_from_number, account_to_number) do
    {:ok, from_balance} = AccountService.get_account_balance_by_number(account_from_number, true)

    {:ok, to_balance} = AccountService.get_account_balance_by_number(account_to_number, true)

    {:ok,
     %{
       account_from_new_balance: from_balance,
       account_to_new_balance: to_balance
     }}
  end

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

  defp validate_split_params(split_details, amount) do
    cond do
      !is_list(split_details) ->
        {:error, "Invalid split details! Must be a list"}

      Enum.empty?(split_details) ->
        {:error, "Empty split details!"}

      !is_integer(amount) ->
        {:error, "Invalid amount! Must be a integer value!"}

      amount <= 0 ->
        {:error, "Invalid amount! Must be bigger than 0!"}

      true ->
        {:ok, true}
    end
  end
end

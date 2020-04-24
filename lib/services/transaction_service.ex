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

  def split(account_from_number, split_details, total_amount) do
    validate_params = validate_split_params(account_from_number, split_details, total_amount)

    case validate_params do
      {:error, _error} ->
        validate_params

      {:ok, _ok} ->
        account_from = AccountService.get_account_by_number(account_from_number)
        validate_percentage = valid_split_percentage?(split_details)

        validate_split_accounts = valid_split_accounts?(account_from_number, split_details)

        cond do
          account_from.balance < total_amount ->
            {:error, "Insufficient funds!"}

          !account_from ->
            {:error, "Account from not found!"}

          !validate_percentage ->
            {:error, "Invalid split percentage in accounts!"}

          validate_split_accounts !== true ->
            {:error, validate_split_accounts}

          true ->
            execute_split(account_from_number, split_details, total_amount)

            {:ok, true}
        end
    end
  end

  @spec get_all_transactions :: any
  def get_all_transactions do
    DB.all(
      Transaction
      |> select([transaction], transaction)
    )
  end

  defp execute_split(account_number_from, split_details, total_amount) do
    Enum.each(split_details, fn detail ->
      amount_transfer = total_amount - detail.percentage * total_amount / 100

      transfer(account_number_from, detail.account_number, trunc(amount_transfer))
    end)
  end

  defp valid_split_percentage?(split_details) do
    total_percentage = get_total_split_percentage(split_details)

    total_percentage <= 100 && total_percentage > 0
  end

  defp get_total_split_percentage(split_details) do
    Enum.reduce(split_details, fn x, y -> x.percentage + y.percentage end)
  end

  defp valid_split_accounts?(account_from_number, split_details) do
    account_from = AccountService.get_account_by_number(account_from_number)

    valid_accounts =
      Enum.reduce_while(split_details, [], fn el, _acc ->
        account = AccountService.get_account_by_number(el.account_number)

        case account do
          nil ->
            {:halt, "Account #{el.account_number} not found!"}

          false ->
            {:halt, "Account #{el.account_number} not found!"}

          _ ->
            if account_from.currency != account.currency do
              {:halt, "Split between accounts with diferrent currencies isn't available yet."}
            else
              {:cont, true}
            end
        end
      end)

    valid_accounts
  end

  @spec has_funds?(any, any, any, binary) :: boolean
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

  defp validate_split_params(account_number_from, split_details, amount) do
    cond do
      !is_integer(account_number_from) ->
        {:error, "Invalid account number from! Must be a integer value!"}

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

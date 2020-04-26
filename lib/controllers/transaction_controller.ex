defmodule TransactionController do
  @moduledoc """
  Transaction controller, handle mostly the api requests.
  """

  @doc """
  Make a new deposit via api.

  ## Parameters

    - body: Struct that represents all the account data to be deposited.

  ## Examples

    deposit = %{"account_number" => 123, "currency" => "brl", "amount" => 1000}

    TransactionController.deposit(deposit)

  """
  @spec deposit(%{}) :: %{error: String.t() | nil, result: any}
  def deposit(body) do
    do_deposit =
      TransactionService.deposit(
        body["account_number"],
        body["currency"],
        body["amount"]
      )

    case do_deposit do
      {:error, error} ->
        Response.response(error, true)

      {:ok, result} ->
        Response.response(result)
    end
  end

  @doc """
  Make a new withdraw via api.

  ## Parameters

    - body: Struct that represents all the account data to be withdrawed.

  ## Examples

    withdraw = %{"account_number" => 123, "currency" => "brl", "amount" => 1000}

    TransactionController.withdraw(withdraw)

  """
  @spec withdraw(%{}) :: %{error: String.t() | nil, result: any}
  def withdraw(body) do
    do_withdraw =
      TransactionService.withdraw(
        body["account_number"],
        body["currency"],
        body["amount"]
      )

    case do_withdraw do
      {:error, error} ->
        Response.response(error, true)

      {:ok, result} ->
        Response.response(result)
    end
  end

  @doc """
  Make a new transfer via api.

  ## Parameters

    - body: Struct that represents all the account data to be transfered.

  ## Examples

    transfer = %{"account_number_from" => 123, "account_number_to" => 1234, "amount" => 1000}

    TransactionController.transfer(transfer)

  """
  @spec transfer(%{}) :: %{error: String.t() | nil, result: any}
  def transfer(body) do
    do_transfer =
      TransactionService.transfer(
        body["account_number_from"],
        body["account_number_to"],
        body["amount"]
      )

    case do_transfer do
      {:error, error} ->
        Response.response(error, true)

      {:ok, result} ->
        Response.response(result)
    end
  end

  @doc """
  Make a new split via api.

  ## Parameters

    - body: Struct that represents all the transaction data to be splitted.

  ## Examples

    split = %{
      "split_details" => [
        %{"account_number" => 123, "percentage" => 50},
        %{"account_number" => 1234, "percentage" => 50}
      ],
      "total_amount" => 2000
    }

    TransactionController.split(split)

  """
  @spec split(%{}) :: %{error: String.t() | nil, result: any}
  def split(body) do
    # Basically transform the request body from a map to a struct.
    split_details =
      Enum.reduce(body["split_details"], [], fn value, details ->
        details ++ [%{account_number: value["account_number"], percentage: value["percentage"]}]
      end)

    do_split =
      TransactionService.split(
        split_details,
        body["total_amount"]
      )

    case do_split do
      {:error, error} ->
        Response.response(error, true)

      {:ok, result} ->
        Response.response(result)
    end
  end

  @doc """
  Return all transactions from database via api.

  """
  @spec get_all_transactions() :: %{error: String.t() | nil, result: any}
  def get_all_transactions do
    transactions = TransactionService.get_all_transactions()

    Response.response(transactions)
  end
end

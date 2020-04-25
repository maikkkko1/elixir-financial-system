defmodule AccountController do
  @moduledoc """
  Account controller, handle mostly the api requests.
  """

  def create_account(body) do
    create =
      AccountService.create_account(
        body["name"],
        body["number"],
        body["agency"],
        body["currency"],
        body["balance"]
      )

    case create do
      {:error, error} ->
        Response.response(error, true)

      {:ok, result} ->
        Response.response(result)
    end
  end

  def get_account_by_id(id) do
    account_id = if is_nil(id), do: 0, else: id

    account = account_id |> AccountService.get_account_by_id()

    cond do
      !account ->
        Response.response("Account not found!", true)

      is_nil(account) ->
        Response.response("Account not found!", true)

      true ->
        Response.response(account)
    end
  end

  def get_account_by_number(number) do
    account_number = if is_nil(number), do: false, else: number

    account =
      if !account_number,
        do: false,
        else: account_number |> AccountService.get_account_by_number()

    cond do
      !account ->
        Response.response("Account not found!", true)

      is_nil(account) ->
        Response.response("Account not found!", true)

      true ->
        Response.response(account)
    end
  end

  def get_all_accounts do
    accounts = AccountService.get_all_accounts()

    Response.response(accounts)
  end

  def get_account_balance_by_number(number) do
    account_number = if is_nil(number), do: false, else: number

    balance =
      if !account_number,
        do: false,
        else: account_number |> AccountService.get_account_balance_by_number(true)

    case balance do
      {:error, error} ->
        Response.response(error, true)

      {:ok, result} ->
        Response.response(result)
    end
  end

  def update_account_by_id(id, body) do
    account_id = if is_nil(id), do: 0, else: id

    account = account_id |> String.to_integer() |> AccountService.update_account_by_id(body)

    case account do
      {:error, error} ->
        Response.response(error, true)

      %Account{} ->
        Response.response(account)
    end
  end
end

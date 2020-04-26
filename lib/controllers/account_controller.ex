defmodule AccountController do
  @moduledoc """
  Account controller, handle mostly the api requests.
  """

  @doc """
  Creates a new account via api.

  ## Parameters

    - body: Struct that represents all the account data to be created.

  ## Examples

      account = %{
        "name" => "Maikon",
        "number" => 123,
        "agency" => 1,
        "currency" => "brl",
        "balance" => 1000
      }

      AccountController.create_account(account)

  """
  @spec create_account(%{}) :: %{error: String.t() | nil, result: any}
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

  @doc """
  Return a account by ID via api.

  ## Parameters

    - id: Integer that represents the account id.

  ## Examples

      AccountController.get_account_by_id(1)

  """
  @spec get_account_by_id(integer) :: %{error: String.t() | nil, result: any}
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

  @doc """
  Return a account by NUMBER via api.

  ## Parameters

    - number: Integer that represents the account number.

  ## Examples

      AccountController.get_account_by_number(1)

  """
  @spec get_account_by_number(integer) :: %{error: String.t() | nil, result: any}
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

  @doc """
  Return all accounts from database via api.

  """
  @spec get_all_accounts :: %{error: String.t() | nil, result: any}
  def get_all_accounts do
    accounts = AccountService.get_all_accounts()

    Response.response(accounts)
  end

  @doc """
  Return a account formatted balance by NUMBER via api.

  ## Parameters

    - number: Integer that represents the account number.

  ## Examples

      AccountController.get_account_balance_by_number(1)

  """
  @spec get_account_balance_by_number(integer) :: %{error: String.t() | nil, result: any}
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

  @doc """
  Update a account by ID via api.

  ## Parameters

    - id: Integer that represents the account id.
    - body: Struct that represents all the account data to be updated.

  ## Examples

      update_data = %{"name" => "Test"}

      AccountController.update_account_by_id(1, updated_data)

  """
  @spec update_account_by_id(integer, %{}) :: %{error: String.t() | nil, result: any}
  def update_account_by_id(id, body) do
    account_id = if is_nil(id), do: 0, else: id

    parsed_id =
      if account_id |> is_binary(), do: account_id |> String.to_integer(), else: account_id

    account = parsed_id |> AccountService.update_account_by_id(body)

    case account do
      {:error, error} ->
        Response.response(error, true)

      nil ->
        Response.response("Account not found!", true)

      %Account{} ->
        Response.response(account)
    end
  end
end

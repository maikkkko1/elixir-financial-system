defmodule AccountServiceTest do
  use ExUnit.Case, async: true
  doctest AccountService

  alias FinancialSystem.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "should create a new account with number 123 and balance 10,00" do
    {:ok, account} = create_default_account()

    assert account.number == 123
    assert account.balance == 1000
  end

  test "should create a new account with default currency brl and balance 0" do
    {:ok, account} = AccountService.create_account("Maikon", 123, 111)

    assert account.currency == "BRL"
    assert account.balance == 0
  end

  test "should try create a account with number that already exists" do
    {:ok, _account} = create_default_account()
    {:error, error} = create_default_account()

    assert error == "Account number already exists!"
  end

  test "should try create a account with invalid name type" do
    {:error, error} = AccountService.create_account(1, 1234, 111, "brl", 1000)

    assert error == "Invalid name! Must be a string value!"
  end

  test "should try create a account with invalid number type" do
    {:error, error} = AccountService.create_account("Maikon", "1", 111, "brl", 1000)

    assert error == "Invalid account number! Must be a integer value!"
  end

  test "should try create a account with invalid agency type" do
    {:error, error} = AccountService.create_account("Maikon", 1, "1", "brl", 1000)

    assert error == "Invalid agency! Must be a integer value!"
  end

  test "should try create a account with invalid currency" do
    {:error, error} = AccountService.create_account("Maikon", 1, 1, "randomcurrency", 1000)

    assert error == "Invalid currency!"
  end

  test "should try create a account with invalid balance type" do
    {:error, error_float} = AccountService.create_account("Maikon", 1, 1, "brl", 10.00)
    {:error, error_string} = AccountService.create_account("Maikon", 1, 1, "brl", "1000")

    assert error_float == "Invalid balance! Must be a integer value!"
    assert error_string == "Invalid balance! Must be a integer value!"
  end

  test "should get account balance without format" do
    {:ok, _account} = create_default_account()
    {:ok, balance} = AccountService.get_account_balance_by_number(123)

    assert balance == 1000
  end

  test "should get account balance with format" do
    {:ok, _account} = create_default_account()
    {:ok, balance} = AccountService.get_account_balance_by_number(123, true)

    assert balance == "10,00"
  end

  test "should try get account balance from a non exists account" do
    {:error, error} = AccountService.get_account_balance_by_number(1)

    assert error == "Account not found"
  end

  test "should get account by number" do
    {:ok, _account} = create_default_account()

    acc = AccountService.get_account_by_number(123)

    assert acc.number == 123
  end

  test "should get account by number that dont exists" do
    acc = AccountService.get_account_by_number(123)

    refute acc
  end

  test "should get account by number with invalid account number" do
    acc = AccountService.get_account_by_number("123")

    refute acc
  end

  test "should get account by id" do
    {:ok, account} = create_default_account()

    acc = AccountService.get_account_by_id(account.id)

    assert acc.number == 123
  end

  test "should get account by id that dont exists" do
    acc = AccountService.get_account_by_id(1)

    refute acc
  end

  test "should get account by number with invalid id" do
    acc = AccountService.get_account_by_id("1")

    refute acc
  end

  test "should get all accounts, expected a list containing 3 values" do
    {:ok, _1} = create_default_account(123)
    {:ok, _2} = create_default_account(1234)
    {:ok, _3} = create_default_account(12345)

    accounts = AccountService.get_all_accounts()

    assert accounts |> length == 3
  end

  test "should get all accounts, expecetd a empty list" do
    accounts = AccountService.get_all_accounts()

    assert accounts == []
  end

  test "should update the account name and currency by id" do
    {:ok, account} = create_default_account()

    update_values = %{name: "Test", currency: "EUR"}

    updated_account = AccountService.update_account_by_id(account.id, update_values)

    assert updated_account.name == "Test"
    assert updated_account.currency == "EUR"
  end

  test "should try update the account protected field number by id" do
    {:ok, account} = create_default_account()

    update_values = %{number: 222}

    updated_account = AccountService.update_account_by_id(account.id, update_values)

    # Number should still be 123
    assert updated_account.number == 123
  end

  def create_default_account(account_number \\ 123) do
    AccountService.create_account("Maikon", account_number, 111, "brl", 1000)
  end
end

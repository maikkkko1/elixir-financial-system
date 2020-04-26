defmodule AccountControllerTest do
  use ExUnit.Case, async: false
  doctest AccountController

  alias FinancialSystem.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "should create a new account" do
    create = create_default_account()

    assert create.result.name == "Maikon"
  end

  test "should try create a new account with invalid name" do
    account = %{
      "name" => 123,
      "number" => 123,
      "agency" => 1,
      "currency" => "brl",
      "balance" => 1000
    }

    create = AccountController.create_account(account)

    assert create.error == "Invalid name! Must be a string value!"
  end

  test "should try create a new account with invalid number" do
    account = %{
      "name" => "Maikon",
      "number" => "123",
      "agency" => 1,
      "currency" => "brl",
      "balance" => 1000
    }

    create = AccountController.create_account(account)

    assert create.error == "Invalid account number! Must be a integer value!"
  end

  test "should try create a new account with invalid agency" do
    account = %{
      "name" => "Maikon",
      "number" => 123,
      "agency" => "1",
      "currency" => "brl",
      "balance" => 1000
    }

    create = AccountController.create_account(account)

    assert create.error == "Invalid agency! Must be a integer value!"
  end

  test "should try create a new account with invalid currency" do
    account = %{
      "name" => "Maikon",
      "number" => 123,
      "agency" => 1,
      "currency" => "randomcurrency",
      "balance" => 1000
    }

    create = AccountController.create_account(account)

    assert create.error == "Invalid currency!"
  end

  test "should try create a new account with invalid balance type" do
    account = %{
      "name" => "Maikon",
      "number" => 123,
      "agency" => 1,
      "currency" => "brl",
      "balance" => "1000"
    }

    create = AccountController.create_account(account)

    assert create.error == "Invalid balance! Must be a integer value!"
  end

  test "should try create a new account with a account number that already exists" do
    create_default_account()

    create_account2 = create_default_account()

    assert create_account2.error == "Account number already exists!"
  end

  test "should get a account by id" do
    create_default_account()

    account = AccountController.get_account_by_id(1)

    assert account.result.name == "Maikon"
  end

  test "should try get a account by id with non exists id" do
    account = AccountController.get_account_by_id(1)

    assert account.error == "Account not found!"
  end

  test "should try get a account by id with nil id" do
    account = AccountController.get_account_by_id(nil)

    assert account.error == "Account not found!"
  end

  test "should get a account by number" do
    create_default_account()

    account = AccountController.get_account_by_number(123)

    assert account.result.name == "Maikon"
  end

  test "should try get a account by id with non exists number" do
    account = AccountController.get_account_by_number(1)

    assert account.error == "Account not found!"
  end

  test "should try get a account by id with nil number" do
    account = AccountController.get_account_by_number(nil)

    assert account.error == "Account not found!"
  end

  test "should get a account formatted balance by number" do
    create_default_account()

    balance = AccountController.get_account_balance_by_number(123)

    assert balance.result == "10,00"
  end

  test "should try get a account formatted balance by number with non exists number" do
    balance = AccountController.get_account_balance_by_number(123)

    assert balance.error == "Account not found"
  end

  test "should update a account name by id" do
    create_default_account

    updated_account = AccountController.update_account_by_id(1, %{"name" => "Test name"})

    assert updated_account.result.name == "Test name"
  end

  test "should try update a account protected field by id" do
    create_default_account

    updated_account = AccountController.update_account_by_id(1, %{"number" => 444})

    assert updated_account.result.number == 123
  end

  test "should try update a account by id with non exists number" do
    updated_account = AccountController.update_account_by_id(1, %{"number" => 444})

    assert updated_account.error == "Account not found!"
  end

  test "should get all accounts from database, expected a list with 3 records" do
    create_default_account()
    create_default_account(1234)
    create_default_account(12345)

    accounts = AccountController.get_all_accounts()

    assert accounts.result |> length == 3
  end

  test "should get all accounts from database, expected a empty list" do
    accounts = AccountController.get_all_accounts()

    assert accounts.result == []
  end

  def create_default_account(number \\ 123) do
    account = %{
      "name" => "Maikon",
      "number" => number,
      "agency" => 1,
      "currency" => "brl",
      "balance" => 1000
    }

    AccountController.create_account(account)
  end
end

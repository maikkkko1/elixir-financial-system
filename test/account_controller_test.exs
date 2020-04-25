defmodule AccountControllerTest do
  use ExUnit.Case, async: true
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

  def create_default_account do
    account1 = %{
      "name" => "Maikon",
      "number" => 123,
      "agency" => 1,
      "currency" => "brl",
      "balance" => 1000
    }

    AccountController.create_account(account1)
  end
end

defmodule TransactionServiceTest do
  use ExUnit.Case, async: true
  doctest TransactionService

  alias FinancialSystem.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "should make a new deposit to account number 123, with BRL and amount of 10,00" do
    {:ok, _account} = create_default_account()

    {:ok, result} = TransactionService.deposit(123, "brl", 1000)

    assert result.balance == 1000
  end

  test "should try make a deposit with invalid account number" do
    {:error, error} = TransactionService.deposit("123", "brl", 1000)

    assert error == "Invalid account number! Must be a integer value!"
  end

  test "should try make a deposit with invalid currency" do
    {:error, error} = TransactionService.deposit(123, "randomcurrency", 1000)

    assert error == "Invalid currency!"
  end

  test "should try make a deposit to a non exist account" do
    {:error, error} = TransactionService.deposit(123, "brl", 1000)

    assert error == "Account not found!"
  end

  test "should try make a deposit with invalid amount" do
    {:error, error1} = TransactionService.deposit(123, "brl", "1000")
    {:error, error2} = TransactionService.deposit(123, "brl", 0)

    assert error1 == "Invalid amount! Must be a integer value!"
    assert error2 == "Invalid amount! Must be bigger than 0!"
  end

  test "should make a new withdraw to account number 123, with BRL and amount of 10,00" do
    {:ok, _account} = create_default_account(123, "brl", 1500)

    {:ok, result} = TransactionService.withdraw(123, "brl", 1000)

    assert result.balance == 500
  end

  test "should try make a withdraw with insufficient funds" do
    {:ok, _account} = create_default_account(123, "brl", 1000)

    {:error, error} = TransactionService.withdraw(123, "brl", 2000)

    assert error == "Insufficient funds!"
  end

  test "should try make a withdraw with invalid account number" do
    {:error, error} = TransactionService.withdraw("123", "brl", 1000)

    assert error == "Invalid account number! Must be a integer value!"
  end

  test "should try make a withdraw with invalid currency" do
    {:error, error} = TransactionService.withdraw(123, "randomcurrency", 1000)

    assert error == "Invalid currency!"
  end

  test "should try make a withdraw to a non exist account" do
    {:error, error} = TransactionService.withdraw(123, "brl", 1000)

    assert error == "Account not found!"
  end

  test "should try make a withdraw with invalid amount" do
    {:error, error1} = TransactionService.withdraw(123, "brl", "1000")
    {:error, error2} = TransactionService.withdraw(123, "brl", 0)

    assert error1 == "Invalid amount! Must be a integer value!"
    assert error2 == "Invalid amount! Must be bigger than 0!"
  end

  test "should make a new transfer from account number 123 to account number 1234, with BRL a amount of 10,00" do
    {:ok, _account1} = create_default_account(123, "brl", 2000)
    {:ok, _account1} = create_default_account(1234)

    {:ok, result} = TransactionService.transfer(123, 1234, 1000)

    assert result.account_to_new_balance == "10,00"
    assert result.account_from_new_balance == "10,00"
  end

  test "should try make a transfer with insufficient funds" do
    {:ok, _account1} = create_default_account(123, "brl", 1000)
    {:ok, _account1} = create_default_account(1234)

    {:error, error} = TransactionService.transfer(123, 1234, 2000)

    assert error == "Insufficient funds!"
  end

  test "should try make a tranfer with invalid account number from" do
    {:error, error} = TransactionService.transfer("123", 1234, 2000)

    assert error == "Invalid account number from! Must be a integer value!"
  end

  test "should try make a tranfer with invalid account number to" do
    {:error, error} = TransactionService.transfer(123, "1234", 2000)

    assert error == "Invalid account number to! Must be a integer value!"
  end

  test "should try make a tranfer with invalid amount" do
    {:error, error1} = TransactionService.transfer(123, 1234, "2000")
    {:error, error2} = TransactionService.transfer(123, 1234, 0)

    assert error1 == "Invalid amount! Must be a integer value!"
    assert error2 == "Invalid amount! Must be bigger than 0!"
  end

  test "should try make a tranfer with a non exist account number from" do
    {:ok, _account1} = create_default_account(1234)
    {:error, error} = TransactionService.transfer(123, 1234, 2000)

    assert error == "Account from not found!"
  end

  test "should try make a tranfer with a non exist account number to" do
    {:ok, _account1} = create_default_account(123)
    {:error, error} = TransactionService.transfer(123, 1234, 2000)

    assert error == "Account to not found!"
  end

  test "should make a new split transaction between account number 123 and account number 1234" do
    {:ok, _account1} = create_default_account(123)
    {:ok, _account2} = create_default_account(1234)

    split_detail = [
      %{account_number: 123, percentage: 25},
      %{account_number: 1234, percentage: 75}
    ]

    {:ok, _split} = TransactionService.split(split_detail, 2000)

    {:ok, account1_new_balance} = AccountService.get_account_balance_by_number(123)
    {:ok, account2_new_balance} = AccountService.get_account_balance_by_number(1234)

    assert account1_new_balance == 500
    assert account2_new_balance == 1500
  end

  test "should try make a split transaction with invalid split_detail type" do
    {:error, error} = TransactionService.split(1, 2000)

    assert error == "Invalid split details! Must be a list"
  end

  test "should try make a split transaction with empty split_detail list" do
    {:error, error} = TransactionService.split([], 2000)

    assert error == "Empty split details!"
  end

  test "should try make a split transaction with invalid split percentages" do
    split_detail = [
      %{account_number: 123, percentage: 50},
      %{account_number: 1234, percentage: 75}
    ]

    {:error, error} = TransactionService.split(split_detail, 2000)

    assert error ==
             "Invalid split percentage in accounts! The sum of all percentages must be 100."
  end

  test "should try make a split transaction with non exist account" do
    split_detail = [
      %{account_number: 11111, percentage: 25},
      %{account_number: 1234, percentage: 75}
    ]

    {:error, error} = TransactionService.split(split_detail, 2000)

    assert error == "Account 11111 not found!"
  end

  test "should try make a split transaction with invalid amount" do
    split_detail = [
      %{account_number: 123, percentage: 25},
      %{account_number: 1234, percentage: 75}
    ]

    {:error, error1} = TransactionService.split(split_detail, "1000")
    {:error, error2} = TransactionService.split(split_detail, 0)

    assert error1 == "Invalid amount! Must be a integer value!"
    assert error2 == "Invalid amount! Must be bigger than 0!"
  end

  test "should get all transactions" do
    {:ok, _account1} = create_default_account(123)
    {:ok, _account2} = create_default_account(1234)

    {:ok, _deposit1} = TransactionService.deposit(123, "brl", 1000)
    {:ok, _deposit2} = TransactionService.deposit(1234, "brl", 1000)

    result = TransactionService.get_all_transactions()

    assert result |> length == 2
  end

  test "should get all transactions with empty list" do
    result = TransactionService.get_all_transactions()

    assert result == []
  end

  def create_default_account(account_number \\ 123, currency \\ "brl", balance \\ 0) do
    AccountService.create_account("Maikon", account_number, 111, currency, balance)
  end
end

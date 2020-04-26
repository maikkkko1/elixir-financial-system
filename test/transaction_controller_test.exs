defmodule TransactionControllerTest do
  use ExUnit.Case, async: false
  doctest TransactionController

  alias FinancialSystem.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "should get all transactions from database, 2 records" do
    create_default_account()

    TransactionController.deposit(%{
      "account_number" => 123,
      "currency" => "brl",
      "amount" => 1000
    })

    TransactionController.deposit(%{
      "account_number" => 123,
      "currency" => "brl",
      "amount" => 1000
    })

    transactions = TransactionController.get_all_transactions()

    assert transactions.result |> length == 2
  end

  test "should get all transactions from database, empty list" do
    transactions = TransactionController.get_all_transactions()

    assert transactions.result == []
  end

  test "should make a new deposit" do
    create_default_account()

    deposit =
      TransactionController.deposit(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => 1000
      })

    assert deposit.result.balance == 2000
  end

  test "should make a new deposit with invalid account number" do
    deposit =
      TransactionController.deposit(%{
        "account_number" => "123",
        "currency" => "brl",
        "amount" => 1000
      })

    assert deposit.error == "Invalid account number! Must be a integer value!"
  end

  test "should make a new deposit with invalid currency" do
    deposit =
      TransactionController.deposit(%{
        "account_number" => 123,
        "currency" => "randomcurrency",
        "amount" => 1000
      })

    assert deposit.error == "Invalid currency!"
  end

  test "should make a new deposit with a non exist account" do
    deposit =
      TransactionController.deposit(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => 1000
      })

    assert deposit.error == "Account not found!"
  end

  test "should make a new deposit with invalid amount" do
    deposit1 =
      TransactionController.deposit(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => 0
      })

    deposit2 =
      TransactionController.deposit(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => "1000"
      })

    assert deposit1.error == "Invalid amount! Must be bigger than 0!"
    assert deposit2.error == "Invalid amount! Must be a integer value!"
  end

  test "should make a new withdraw" do
    create_default_account()

    withdraw =
      TransactionController.withdraw(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => 1000
      })

    assert withdraw.result.balance == 0
  end

  test "should make a new withdraw with invalid account number" do
    withdraw =
      TransactionController.withdraw(%{
        "account_number" => "123",
        "currency" => "brl",
        "amount" => 1000
      })

    assert withdraw.error == "Invalid account number! Must be a integer value!"
  end

  test "should make a new withdraw with invalid currency" do
    withdraw =
      TransactionController.withdraw(%{
        "account_number" => 123,
        "currency" => "randomcurrency",
        "amount" => 1000
      })

    assert withdraw.error == "Invalid currency!"
  end

  test "should make a new withdraw with a non exist account" do
    withdraw =
      TransactionController.withdraw(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => 1000
      })

    assert withdraw.error == "Account not found!"
  end

  test "should make a new withdraw with insufficient funds" do
    create_default_account()

    withdraw =
      TransactionController.withdraw(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => 10000
      })

    assert withdraw.error == "Insufficient funds!"
  end

  test "should make a new withdraw with invalid amount" do
    withdraw1 =
      TransactionController.withdraw(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => 0
      })

    withdraw2 =
      TransactionController.withdraw(%{
        "account_number" => 123,
        "currency" => "brl",
        "amount" => "1000"
      })

    assert withdraw1.error == "Invalid amount! Must be bigger than 0!"
    assert withdraw2.error == "Invalid amount! Must be a integer value!"
  end

  test "should make a new transfer" do
    create_default_account()
    create_default_account(1234)

    transfer =
      TransactionController.transfer(%{
        "account_number_from" => 123,
        "account_number_to" => 1234,
        "amount" => 1000
      })

    assert transfer.result.account_from_new_balance == "0,00"
    assert transfer.result.account_to_new_balance == "20,00"
  end

  test "should make a new transfer with invalid account number from" do
    transfer =
      TransactionController.transfer(%{
        "account_number_from" => "123",
        "account_number_to" => 1234,
        "amount" => 1000
      })

    assert transfer.error == "Invalid account number from! Must be a integer value!"
  end

  test "should make a new transfer with invalid account number to" do
    transfer =
      TransactionController.transfer(%{
        "account_number_from" => 123,
        "account_number_to" => "1234",
        "amount" => 1000
      })

    assert transfer.error == "Invalid account number to! Must be a integer value!"
  end

  test "should make a new transfer with a non exist account from" do
    create_default_account(1234)

    transfer =
      TransactionController.transfer(%{
        "account_number_from" => 123,
        "account_number_to" => 1234,
        "amount" => 1000
      })

    assert transfer.error == "Account from not found!"
  end

  test "should make a new transfer with a non exist account to" do
    create_default_account()

    transfer =
      TransactionController.transfer(%{
        "account_number_from" => 123,
        "account_number_to" => 1234,
        "amount" => 1000
      })

    assert transfer.error == "Account to not found!"
  end

  test "should make a new transfer with insufficient funds" do
    create_default_account()
    create_default_account(1234)

    transfer =
      TransactionController.transfer(%{
        "account_number_from" => 123,
        "account_number_to" => 1234,
        "amount" => 5000
      })

    assert transfer.error == "Insufficient funds!"
  end

  test "should make a new transfer with invalid amount" do
    transfer1 =
      TransactionController.transfer(%{
        "account_number_from" => 123,
        "account_number_to" => 1234,
        "amount" => 0
      })

    transfer2 =
      TransactionController.transfer(%{
        "account_number_from" => 123,
        "account_number_to" => 1234,
        "amount" => "1000"
      })

    assert transfer1.error == "Invalid amount! Must be bigger than 0!"
    assert transfer2.error == "Invalid amount! Must be a integer value!"
  end

  test "should make a new split between 2 accounts" do
    create_default_account()
    create_default_account(1234)

    body = %{
      "split_details" => [
        %{"account_number" => 123, "percentage" => 50},
        %{"account_number" => 1234, "percentage" => 50}
      ],
      "total_amount" => 1000
    }

    split = TransactionController.split(body)

    assert split.result == true
  end

  test "should make a new split between 2 accounts with invalid percentage (101%)" do
    body = %{
      "split_details" => [
        %{"account_number" => 123, "percentage" => 51},
        %{"account_number" => 1234, "percentage" => 50}
      ],
      "total_amount" => 1000
    }

    split = TransactionController.split(body)

    assert split.error ==
             "Invalid split percentage in accounts! The sum of all percentages must be 100."
  end

  test "should make a new split between 2 accounts with a non exists account" do
    body = %{
      "split_details" => [
        %{"account_number" => 123, "percentage" => 50},
        %{"account_number" => 1234, "percentage" => 50}
      ],
      "total_amount" => 1000
    }

    split = TransactionController.split(body)

    assert split.error == "Account 123 not found!"
  end

  test "should make a new split between 2 accounts with invalid amount" do
    body1 = %{
      "split_details" => [
        %{"account_number" => 123, "percentage" => 50},
        %{"account_number" => 1234, "percentage" => 50}
      ],
      "total_amount" => "1000"
    }

    body2 = %{
      "split_details" => [
        %{"account_number" => 123, "percentage" => 50},
        %{"account_number" => 1234, "percentage" => 50}
      ],
      "total_amount" => 0
    }

    split1 = TransactionController.split(body1)
    split2 = TransactionController.split(body2)

    assert split1.error == "Invalid amount! Must be a integer value!"
    assert split2.error == "Invalid amount! Must be bigger than 0!"
  end

  test "should make a new split between 2 accounts with empty details list" do
    create_default_account()
    create_default_account(1234)

    body = %{
      "split_details" => [],
      "total_amount" => 1000
    }

    split = TransactionController.split(body)

    assert split.error == "Empty split details!"
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

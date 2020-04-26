defmodule TransactionRouter do
  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  post "/deposit" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(TransactionController.deposit(conn.body_params)))
  end

  post "/withdraw" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(TransactionController.withdraw(conn.body_params)))
  end

  post "/transfer" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(TransactionController.transfer(conn.body_params)))
  end

  post "/split" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(TransactionController.split(conn.body_params)))
  end

  get "/all" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(TransactionController.get_all_transactions()))
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, Poison.encode!(%{error: "Requested endpoint not found!"}))
  end
end

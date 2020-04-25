defmodule AccountRouter do
  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  post "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(AccountController.create_account(conn.body_params)))
  end

  put "/:id" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      200,
      Poison.encode!(AccountController.update_account_by_id(id, conn.body_params))
    )
  end

  get "/byId/:id" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(AccountController.get_account_by_id(id)))
  end

  get "/byNumber/:number" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(AccountController.get_account_by_number(number)))
  end

  get "/balance/:number" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(AccountController.get_account_balance_by_number(number)))
  end

  get "/all" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(AccountController.get_all_accounts()))
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, Poison.encode!(%{error: "Requested endpoint not found!"}))
  end
end

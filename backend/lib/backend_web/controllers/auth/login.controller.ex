defmodule BackendWeb.LoginController do
  use BackendWeb, :controller
  alias Backend.Accounts

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user, %{})

        conn
        |> Plug.Conn.put_resp_cookie("auth_token", token, http_only: true, secure: true, max_age: 60 * 60 * 24 * 7)
        |> Plug.Conn.put_resp_cookie("user_id", user.id, max_age: 60 * 60 * 24 * 7)
        |> json(%{message: "Login successful", token: token})

      {:error, reason} ->
        conn
        |> Plug.Conn.put_status(:unauthorized)
        |> json(%{message: reason})
    end
  end

  def logout(conn, _) do
    conn
    |> Plug.Conn.delete_resp_cookie("auth_token")
    |> Plug.Conn.delete_resp_cookie("user_id")
    |> Plug.Conn.put_status(:ok)
    |> json(%{message: "Logout successful"})
  end
end

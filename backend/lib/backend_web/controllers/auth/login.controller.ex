defmodule BackendWeb.LoginController do
  use BackendWeb, :controller
  alias Backend.Accounts
  alias Backend.TranslateMessages

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        if user.email_confirmed do
          {:ok, token, _claims} = Backend.GuardianAuth.encode_and_sign(user, %{})
          conn
          |> Plug.Conn.put_resp_cookie("cryptum_token", token, http_only: true, secure: true, same_site: "Lax", max_age: 60 * 60 * 24 * 7)
          |> json(TranslateMessages.as_single_success("Login successful"))
        else
          conn
          |> Plug.Conn.put_status(:unauthorized)
          |> json(TranslateMessages.as_single_error("Email not confirmed"))
        end
      {:error, reason} ->
        conn
        |> Plug.Conn.put_status(:unauthorized)
        |> json(TranslateMessages.as_single_error(reason))
    end
  end

  def logout(conn, _) do
    conn
    |> Plug.Conn.delete_resp_cookie("auth_token")
    |> Plug.Conn.delete_resp_cookie("user_id")
    |> Plug.Conn.put_status(:ok)
    |> json(TranslateMessages.as_single_success("Logout successful"))
  end

  def me(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    json(conn, %{id: user.id, name: user.name})
  end
end

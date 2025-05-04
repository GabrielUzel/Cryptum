defmodule AuthServiceWeb.LoginController do
  # import AuthService.TranslateErrors
  use AuthServiceWeb, :controller
  alias AuthService.Accounts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    Accounts.authenticate_user(email, password)
    |> login_reply(conn)
  end

  def logout(conn, _) do
    conn
    |> delete_resp_cookie("auth_token")
    |> redirect(to: "/auth/login")
  end

  defp login_reply({:ok, user}, conn) do
    {:ok, token, _claims} = AuthService.GuardianAuth.encode_and_sign(user)

    conn
    |> Plug.Conn.put_resp_cookie("auth_token", token, http_only: true, secure: true, max_age: 60 * 60 * 24 * 7)
    |> redirect(external: "http://localhost:4001/home")
  end

  defp login_reply({:error, reason}, conn) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      errors: [
        %{message: to_string(reason)}
      ]
    })
  end
end

defmodule BackendWeb.LoginController do
  use BackendWeb, :controller
  alias Backend.AccountsRepository
  alias Backend.TranslateMessages
  alias BackendWeb.MailerHandler

  def login(conn, %{"email" => email, "password" => password}) do
    case AccountsRepository.authenticate_user(email, password) do
      {:ok, user} ->
        if user.email_confirmed do
          {:ok, token, _claims} = Backend.GuardianAuth.encode_and_sign(user, %{})
          conn
          |> Plug.Conn.put_resp_cookie("cryptum_token", token, http_only: true, secure: false, path: "/", same_site: "Lax", max_age: 60 * 60 * 24 * 7) # ! Está secure: false apenas em dev
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
    |> Plug.Conn.delete_resp_cookie("cryptum_token", path: "/")
    |> Plug.Conn.clear_session()
    |> Plug.Conn.put_status(:ok)
    |> json(TranslateMessages.as_single_success("Logout successful"))
  end

  def me(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> Plug.Conn.put_status(:unauthorized)
        |> json(%{error: "Not authenticated"})
      user ->
        json(conn, %{id: user.id, name: user.name})
    end
  end

  def email_reset_password(conn, %{"email" => email}) do
    case AccountsRepository.get_user_by_email(email) do
      nil ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Email sent"})

      user ->
        token = Phoenix.Token.sign(BackendWeb.Endpoint, "reset_password", user.id)
        reset_url = "http://localhost:3000/auth/reset-password/confirmation?token=#{token}"

        case MailerHandler.reset_password(email, reset_url) do
          {:ok, _} ->
            conn
            |> put_status(:ok)
            |> json(TranslateMessages.as_single_success("Email sent"))
          {:error, _} ->
            conn
            |> put_status(:internal_server_error)
            |> json(TranslateMessages.as_single_error("Internal error"))
        end
    end
  end

  def reset_password(conn, %{"token" => token, "password" => password}) do
    with {:ok, user_id} <- Phoenix.Token.verify(BackendWeb.Endpoint, "reset_password", token, max_age: 3600),
      user when not is_nil(user) <- AccountsRepository.get_user_by_id(user_id),
      _changeset <- Ecto.Changeset.change(user, %{}),
      {:ok, hashed} <- {:ok, Argon2.hash_pwd_salt(password)},
      {:ok, _updated_user} <- Backend.Repo.update(Ecto.Changeset.change(user, hashed_password: hashed)) do

      conn
        |> put_status(:ok)
        |> json(%{message: "Password updated successfully"})

    else
      {:error, :invalid} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired token"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not update password"})
    end
  end
end

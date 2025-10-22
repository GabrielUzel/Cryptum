defmodule BackendWeb.RegisterController do
  use BackendWeb, :controller
  alias Backend.AccountsRepository
  alias Backend.TranslateMessages
  alias BackendWeb.MailerHandler

  def create(conn, %{"name" => name, "email" => email, "password" => password}) do
    user_params = %{
      "name" => name,
      "email" => email,
      "password" => password
    }

    case AccountsRepository.create_user(user_params) do
      {:ok, user} ->
        token = Phoenix.Token.sign(BackendWeb.Endpoint, "confirm", user.id, max_age: 86400)

        frontend_base_url =
          Application.get_env(:backend, :frontend_url) || "http://localhost:3000"

        confirmation_url = frontend_base_url <> "/auth/register/confirm?token=#{token}"

        case MailerHandler.confirm_register(email, confirmation_url) do
          {:ok, _} ->
            conn
            |> put_status(:created)
            |> json(
              TranslateMessages.as_single_success(
                "User created successfully. A confirmation email has been sent."
              )
            )

          {:error, _} ->
            conn
            |> put_status(:internal_server_error)
            # TODO: User still exists if email failed, delete user if this happens
            |> json(
              TranslateMessages.as_single_error(
                "User created, but failed to send confirmation email."
              )
            )
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(TranslateMessages.as_error_array(changeset))
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Phoenix.Token.verify(BackendWeb.Endpoint, "confirm", token, max_age: 86400) do
      {:ok, user_id} ->
        case AccountsRepository.get_user_by_id(user_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(TranslateMessages.as_single_error("User not found"))

          user ->
            case AccountsRepository.update_user_email_confirmed(user) do
              {:ok, _updated_user} ->
                conn
                |> put_status(:ok)
                |> json(TranslateMessages.as_single_success("Email confirmed."))

              {:error, _changeset} ->
                conn
                |> put_status(:internal_server_error)
                |> json(TranslateMessages.as_single_error("Error confirming email."))
            end
        end

      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(TranslateMessages.as_single_error("Invalid or expired token"))
    end
  end
end

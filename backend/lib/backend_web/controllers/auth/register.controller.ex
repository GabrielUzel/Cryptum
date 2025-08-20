defmodule BackendWeb.RegisterController do
  use BackendWeb, :controller
  alias Backend.Accounts

  def create(conn, %{"name" => name, "email" => email, "password" => password}) do
    user_params = %{
      "name" => name,
      "email" => email,
      "password" => password
    }

    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        token = Phoenix.Token.sign(BackendWeb.Endpoint, "confirm", user_params, max_age: 86400)
        confirmation_url = BackendWeb.Router.Helpers.url(conn) <> "/auth/register/confirm?token=#{token}"

        case Backend.MailerHandler.confirm_register(email, confirmation_url) do
          {:ok, _} ->
            conn
            |> put_status(:created)
            |> json(%{message: "User created successfully. A confirmation email has been sent."})
          {:error, _} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "User created, but failed to send confirmation email."})
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        errors =
        Ecto.Changeset.traverse_errors(changeset, fn {error_message, error_options} ->
          Enum.reduce(error_options, error_message, fn {option_key, option_value}, formatted_message ->
            String.replace(formatted_message, "%{#{option_key}}", to_string(option_value))
          end)
        end)
        |> Enum.flat_map(fn {field, messages} ->
          Enum.map(messages, fn message ->
            %{
              field: to_string(field),
              message: message
            }
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Phoenix.Token.verify(BackendWeb.Endpoint, "confirm", token, max_age: 86400) do
      {:ok, %{"email" => email}} ->
        case Backend.Accounts.get_user(email) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "User not found"})
          user ->
            case Backend.Accounts.update_user_email_confirmed(user) do
              {:ok, _updated_user} ->
                conn
                |> put_status(:ok)
                |> json(%{message: "Email confirmado com sucesso!"})
              {:error, _changeset} ->
                conn
                |> put_status(:internal_server_error)
                |> json(%{error: "Erro ao confirmar e-mail"})
            end
        end
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Token inválido ou expirado"})
    end
  end
end

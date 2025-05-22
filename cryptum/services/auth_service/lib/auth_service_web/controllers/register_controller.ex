defmodule AuthServiceWeb.RegisterController do
  import AuthService.TranslateErrors
  use AuthServiceWeb, :controller
  alias AuthService.Accounts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{ "name" => name, "email" => email, "password" => password}) do
    changeset = AuthService.Accounts.User.changeset(%AuthService.Accounts.User{}, %{"name" => name, "email" => email, "password" => password})

    if changeset.valid? do
      case Accounts.get_user(email) do
        nil ->
          token = Phoenix.Token.sign(
            AuthServiceWeb.Endpoint,
            "confirm",
            %{
              email: email,
              name: name,
              password: password
            },
            max_age: 86400);

            confirmation_url = AuthServiceWeb.Router.Helpers.url(conn) <> "/auth/register/confirm?token=#{token}"

            body = %{
              email: email,
              link: confirmation_url
            } |> Jason.encode!()

            HTTPoison.post!("http://localhost:4001/api/auth/confirm/register", body, [
              {"Content-Type", "application/json"}
            ])

            conn
            |> put_status(:accepted)
            |> json(%{message: "Email de confirmação enviado. Verifique sua caixa de entrada."})
        _user ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "Email já cadastrado"})
      end
    else
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
      |> put_status(:bad_request)
      |> json(%{errors: errors})
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Phoenix.Token.verify(AuthServiceWeb.Endpoint, "confirm", token, max_age: 86400) do
      {:ok, %{email: email, name: name, password: password}} ->
        user_params = %{
          "email" => email,
          "name" => name,
          "password" => password
        }

        case Accounts.create_user(user_params) do
          {:ok, _} ->
            conn
            |> put_view(AuthServiceWeb.ConfirmationView)
            |> render("index.html")

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, get_in(translate_errors(changeset), [:errors, Access.at(0), :message]))
            |> put_view(AuthServiceWeb.ConfirmationView)
            |> render("error.html")
        end

        {:error, _} ->
        conn
        |> put_view(AuthServiceWeb.ConfirmationView)
        |> render("error.html")
    end
  end
end

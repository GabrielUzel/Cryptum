defmodule AuthServiceWeb.RegisterController do
  import AuthService.TranslateErrors
  use AuthServiceWeb, :controller
  alias AuthService.Accounts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.get_user(user_params["email"]) do
      nil ->
        token = Phoenix.Token.sign(
          AuthServiceWeb.Endpoint,
          "confirm",
          %{
            email: user_params["email"],
            name: user_params["name"],
            password: user_params["password"]
          },
          max_age: 86400);

          confirmation_url = AuthServiceWeb.Router.Helpers.url(conn) <> "/auth/register/confirm?token=#{token}"

          body = %{
            email: user_params["email"],
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

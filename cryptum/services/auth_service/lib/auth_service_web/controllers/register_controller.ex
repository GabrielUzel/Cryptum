defmodule AuthServiceWeb.RegisterController do
  import AuthService.TranslateErrors
  use AuthServiceWeb, :controller
  alias AuthService.Accounts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _} ->
        conn
        |> json(%{message: "User created successfully"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(translate_errors(changeset))
    end
  end
end

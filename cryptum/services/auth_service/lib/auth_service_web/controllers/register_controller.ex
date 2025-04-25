defmodule AuthServiceWeb.RegisterController do
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
        |> json(translate_errors(changeset))
    end
  end

  defp translate_errors(%Ecto.Changeset{} = changeset) do
    errors = changeset.errors |> Enum.map(fn {field, {message, opts}} ->
      %{
        field: field,
        message: translate_message(message, opts),
      }
    end)

    %{errors: errors}
  end

  defp translate_message(msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end

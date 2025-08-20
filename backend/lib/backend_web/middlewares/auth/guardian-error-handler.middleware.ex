defmodule Backend.GuardianErrorHandler do
  import Plug.Conn

  def unauthenticated(conn, _params) do
    body = %{
      errors: [%{message: "Email or password incorrect"}]
    }

    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(body)
  end

  def unauthorized(conn, _params) do
    body = %{
      errors: [%{message: "Must be logged to acess this page"}]
    }

    conn
    |> put_status(:forbidden)
    |> Phoenix.Controller.json(body)
  end
end

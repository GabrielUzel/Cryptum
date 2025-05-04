defmodule AuthService.GuardianErrorHandler do
  import Plug.Conn

  def unauthenticated(conn, _params) do
    body = %{
      errors: [%{message: "Email ou senha incorretos"}]
    }

    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(body)
  end

  def unauthorized(conn, _params) do
    body = %{
      errors: [%{message: "Faça seu login para acessar essa página"}]
    }

    conn
    |> put_status(:forbidden)
    |> Phoenix.Controller.json(body)
  end
end

defmodule Backend.GuardianErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body =
      case type do
        :unauthenticated ->
          %{errors: [%{message: "Email or password incorrect"}]}

        :unauthorized ->
          %{errors: [%{message: "Must be logged to access this page"}]}

        _ ->
          %{errors: [%{message: "Authentication error"}]}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code(type), Jason.encode!(body))
  end

  defp status_code(:unauthenticated), do: 401
  defp status_code(:unauthorized), do: 403
  defp status_code(_), do: 401
end

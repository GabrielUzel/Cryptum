defmodule AuthServiceWeb.ForgotPasswordController do
  use AuthServiceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

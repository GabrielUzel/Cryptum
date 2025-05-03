defmodule AuthServiceWeb.LoginController do
  import TranslateErrors;
  use AuthServiceWeb, :controller
  alias AuthService.Accounts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def authenticate(conn, %{"user" => user_params}) do
    # case Accounts.get_user(user_params) do

    # end
  end
end

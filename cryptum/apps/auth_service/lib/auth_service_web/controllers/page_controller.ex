defmodule AuthServiceWeb.PageController do
  use AuthServiceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

defmodule DuskWeb.PageController do
  use DuskWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

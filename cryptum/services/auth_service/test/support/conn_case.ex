defmodule AuthServiceWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import AuthServiceWeb.ConnCase

      alias AuthServiceWeb.Router.Helpers, as: Routes

      @endpoint AuthServiceWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AuthService.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(AuthService.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end

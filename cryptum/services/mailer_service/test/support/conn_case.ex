defmodule MailerServiceWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import MailerServiceWeb.ConnCase

      alias MailerServiceWeb.Router.Helpers, as: Routes

      @endpoint MailerServiceWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end

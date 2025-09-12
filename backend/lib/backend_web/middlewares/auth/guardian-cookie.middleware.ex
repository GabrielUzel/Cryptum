defmodule BackendWeb.Plugs.CookieToSession do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    cookie_key = opts[:cookie_key] || "cryptum_token"
    session_key = opts[:session_key] || "guardian_default_token"

    if token = conn.req_cookies[cookie_key] do
      put_session(conn, session_key, token)
    else
      conn
    end
  end
end

defmodule BackendWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :backend
  @session_options [
    store: :cookie,
    key: "_backend_key",
    signing_salt: "/3xzjG2E",
    same_site: "None",
    secure: false # ! Em development, colocar true em produção
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  socket "/socket", BackendWeb.UserSocket,
    websocket: [connect_info: [:peer_data, {:session, @session_options}]],
    longpoll: false

  plug CORSPlug, origin: ["http://localhost:3000"]
  plug Plug.Static,
    at: "/",
    from: :backend,
    gzip: false,
    only: BackendWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :backend
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug BackendWeb.Router
end

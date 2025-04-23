use Mix.Config

config :auth_service, AuthService.Repo,
  username: "root",
  password: "",
  database: "auth_service_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :auth_service, AuthServiceWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn

import Config

config :backend, Backend.Repo,
  username: "root",
  password: "",
  hostname: "localhost",
  database: "backend_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :backend, BackendWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "lb311IffeNLpjwGW5N4lHz4u4CZzl0zK55XgUgzqugDbWpibVtNcIcOdd6E35obL",
  server: false

config :backend, Backend.Mailer, adapter: Swoosh.Adapters.Test
config :swoosh, :api_client, false
config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime

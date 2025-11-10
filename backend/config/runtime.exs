import Config
import Dotenvy

source!(["../.env", ".env.dev", System.get_env()])

if System.get_env("PHX_SERVER") do
  config :backend, BackendWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      Environment variable DATABASE_URL is missing.
      """

  config :backend, BackendWeb.Endpoint,
    url: [
      host: System.fetch_env!("PHX_HOST"),
      port: 443,
      scheme: "https"
    ],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.fetch_env!("PORT"))
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

  config :backend,
    frontend_url: System.get_env("FRONTEND_URL") || raise("FRONTEND_URL not set")

  config :backend, Backend.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  config :backend, Backend.GuardianAuth,
    issuer: "backend",
    secret_key: System.fetch_env!("GUARDIAN_SECRET")

  host = System.get_env("PHX_HOST")
  port = String.to_integer(System.get_env("PORT"))

  config :backend, Backend.Mailer,
    adapter: Swoosh.Adapters.SMTP,
    relay: "smtp.gmail.com",
    username: System.fetch_env!("GMAIL_USERNAME"),
    password: System.fetch_env!("GMAIL_APP_PASSWORD"),
    port: 587,
    ssl: false,
    tls: :always,
    auth: :always,
    tls_options: [
      verify: :verify_none,
      versions: [:"tlsv1.2"]
    ]

  config :backend, BackendWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end

if config_env() in [:dev, :test] do
  config :backend, Backend.Repo,
    username: env!("DB_USER", :string),
    password: env!("DB_PASSWORD", :string),
    hostname: env!("DB_HOST", :string),
    database: env!("DB_NAME", :string),
    port: env!("DB_PORT", :integer),
    pool_size: env!("POOL_SIZE", :integer),
    stacktrace: true,
    show_sensitive_data_on_connection_error: true

  config :backend,
    frontend_url: System.get_env("FRONTEND_URL") || "http://localhost:3000"

  config :backend, Backend.GuardianAuth,
    issuer: "backend",
    secret_key: env!("GUARDIAN_SECRET")

  config :backend, BackendWeb.Endpoint,
    http: [ip: {127, 0, 0, 1}, port: env!("PORT", :integer)],
    secret_key_base: env!("SECRET_KEY_BASE", :string),
    check_origin: false,
    code_reloader: true,
    debug_errors: true,
    watchers: []

  config :azurex, Azurex.Blob.Config,
    api_url: env!("AZURE_API_URL", :string),
    default_container: "cryptum-blob",
    storage_account_name: env!("AZURE_STORAGE_ACCOUNT_NAME", :string),
    storage_account_key: env!("AZURE_STORAGE_ACCOUNT_KEY", :string)

  config :backend, Backend.Mailer,
    adapter: Swoosh.Adapters.SMTP,
    relay: "smtp.gmail.com",
    username: env!("GMAIL_USERNAME", :string),
    password: env!("GMAIL_APP_PASSWORD", :string),
    port: 587,
    ssl: false,
    tls: :always,
    auth: :always,
    tls_options: [
      verify: :verify_none,
      versions: [:"tlsv1.2"]
    ]

  config :swoosh, :api_client, Swoosh.ApiClient.Finch
  config :backend, dev_routes: true
  config :logger, :console, format: "[$level] $message\n"
  config :phoenix, :stacktrace_depth, 20
  config :phoenix, :plug_init_mode, :runtime
end

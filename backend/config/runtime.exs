import Config
import Dotenvy

Dotenvy.source!([".env"])

if System.get_env("PHX_SERVER") do
  config :backend, BackendWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :backend, Backend.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :backend, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

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
    username: env!("DB_USERNAME", :string),
    password: env!("DB_PASSWORD", :string),
    hostname: env!("DB_HOST", :string),
    database: env!("DB_NAME", :string),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    stacktrace: true,
    show_sensitive_data_on_connection_error: true

  config :backend, Backend.GuardianAuth,
    issuer: "backend",
    secret_key: env!("GUARDIAN_SECRET")

  config :backend, BackendWeb.Endpoint,
    http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "4000")],
    secret_key_base: env!("SECRET_KEY_BASE", :string),
    check_origin: false,
    code_reloader: true,
    debug_errors: true,
    watchers: []

  config :azurex, Azurex.Blob.Config,
    api_url: env!("AZURE_API_URL", :string),
    default_container: "projectsfiles",
    storage_account_name: env!("AZURE_STORAGE_ACCOUNT_NAME", :string),
    storage_account_key: env!("AZURE_STORAGE_ACCOUNT_KEY", :string)

  config :backend, Backend.Mailer,
    adapter: Swoosh.Adapters.Sendgrid,
    api_key: env!("SENDGRID_API_KEY", :string)

  config :swoosh, :api_client, Swoosh.ApiClient.Finch
  config :backend, dev_routes: true
  config :logger, :console, format: "[$level] $message\n"
  config :phoenix, :stacktrace_depth, 20
  config :phoenix, :plug_init_mode, :runtime
end

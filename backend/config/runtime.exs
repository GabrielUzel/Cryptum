import Config

if File.exists?(".env") do
  import Dotenvy
  source!([".env"])
end

if System.get_env("PHX_SERVER") do
  config :backend, BackendWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url = env!("DATABASE_URL")
  secret_key_base = env!("SECRET_KEY_BASE")
  port = env!("PORT")
  host = env!("PHX_HOST")
  pool_size = env!("POOL_SIZE")

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :backend, Backend.Repo,
    url: database_url,
    pool_size: String.to_integer(pool_size),
    socket_options: maybe_ipv6

  config :backend, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :backend, BackendWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(port)
    ],
    secret_key_base: secret_key_base

  config :azurex, Azurex.Blob.Config,
    api_url: env!("AZURE_API_URL"),
    default_container: "projectsfiles",
    storage_account_name: env!("AZURE_STORAGE_ACCOUNT_NAME"),
    storage_account_key: env!("AZURE_STORAGE_ACCOUNT_KEY")
end

if config_env() in [:dev, :test] do
  config :backend, Backend.Repo,
    username: env!("POSTGRES_USER"),
    password: env!("POSTGRES_PASSWORD"),
    hostname: env!("POSTGRES_HOST"),
    database: env!("POSTGRES_DB"),
    port: String.to_integer(env!("POSTGRES_PORT")),
    pool_size: String.to_integer(env!("POOL_SIZE")),
    stacktrace: true,
    show_sensitive_data_on_connection_error: true

  config :backend, Backend.GuardianAuth,
    issuer: "backend",
    secret_key: env!("GUARDIAN_SECRET")

  config :backend, BackendWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: String.to_integer(env!("PORT"))],
    secret_key_base: env!("SECRET_KEY_BASE"),
    check_origin: false,
    code_reloader: true,
    debug_errors: true,
    watchers: []

  config :azurex, Azurex.Blob.Config,
    api_url: env!("AZURE_API_URL"),
    default_container: "projectsfiles",
    storage_account_name: env!("AZURE_STORAGE_ACCOUNT_NAME"),
    storage_account_key: env!("AZURE_STORAGE_ACCOUNT_KEY")

  config :backend, Backend.Mailer,
    adapter: Swoosh.Adapters.SMTP,
    relay: "smtp.gmail.com",
    username: env!("GMAIL_USERNAME"),
    password: env!("GMAIL_APP_PASSWORD"),
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

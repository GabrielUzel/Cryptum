import Config
import Dotenvy

sources =
  if config_env() == :dev do
    [".env.dev", System.get_env()]
  else
    [System.get_env()]
  end

source!(sources)

if config_env() == :prod do
  config :backend, BackendWeb.Endpoint, server: true
end

config :backend, Backend.Repo,
  username: env!("DB_USER"),
  password: env!("DB_PASSWORD"),
  hostname: env!("DB_HOST"),
  database: env!("DB_NAME"),
  port: env!("DB_PORT") |> String.to_integer(),
  pool_size: env!("POOL_SIZE") |> String.to_integer()

config :backend, BackendWeb.Endpoint,
  url: [
    host: env!("PHX_HOST"),
    port: env!("PORT") |> String.to_integer(),
    scheme: "http"
  ],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: env!("PORT") |> String.to_integer()
  ],
  secret_key_base: env!("SECRET_KEY_BASE"),
  check_origin: [
    "http://10.0.24.74:8080",
    "//10.0.24.74:8080",
    "http://localhost:3117",
    "//localhost:3117"
  ]

config :backend, :dns_cluster_query, env!("DNS_CLUSTER_QUERY")

config :backend,
  frontend_url: env!("FRONTEND_URL")

config :backend, Backend.GuardianAuth,
  issuer: "backend",
  secret_key: env!("GUARDIAN_SECRET")

config :azurex, Azurex.Blob.Config,
  api_url: env!("AZURE_API_URL"),
  default_container: "cryptumblob",
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

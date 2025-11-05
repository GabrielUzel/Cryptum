import Config

if System.get_env("PHX_SERVER") do
  config :backend, BackendWeb.Endpoint, server: true
end

config :backend, Backend.Repo,
  username: System.fetch_env!("MYSQL_USER"),
  password: System.fetch_env!("MYSQL_PASSWORD"),
  hostname: System.fetch_env!("MYSQL_HOST"),
  database: System.fetch_env!("MYSQL_DB"),
  port: String.to_integer(System.fetch_env!("MYSQL_PORT")),
  pool_size: String.to_integer(System.fetch_env!("POOL_SIZE"))

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

config :backend, :dns_cluster_query, System.fetch_env!("DNS_CLUSTER_QUERY")

config :backend, Backend.GuardianAuth,
  issuer: "backend",
  secret_key: System.fetch_env!("GUARDIAN_SECRET")

config :azurex, Azurex.Blob.Config,
  api_url: System.fetch_env!("AZURE_API_URL"),
  default_container: "projectsfiles",
  storage_account_name: System.fetch_env!("AZURE_STORAGE_ACCOUNT_NAME"),
  storage_account_key: System.fetch_env!("AZURE_STORAGE_ACCOUNT_KEY")

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

config :swoosh, :api_client, Swoosh.ApiClient.Finch

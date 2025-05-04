import Config
import Dotenvy

if Mix.env() in [:dev, :test] do
  env_dir_prefix = System.get_env("RELEASE_ROOT") || Path.expand("./envs/")

  source!([
    Path.absname(".env", env_dir_prefix),
    Path.absname(".#{Mix.env()}.overrides.env", env_dir_prefix)
  ])
end

config :auth_service, AuthService.Repo,
  username: env!("DB_USERNAME", :string),
  password: env!("DB_PASSWORD", :string),
  port: env!("DB_PORT", :integer),
  database: env!("DB_NAME", :string),
  hostname: env!("DB_HOST", :string)

config :auth_service, AuthServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: env!("ENDPOINT_SECRET", :string),
  render_errors: [view: AuthServiceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AuthService.PubSub,
  live_view: [signing_salt: env!("ENDPOINT_SALT", :string)]

config :auth_service, AuthService.GuardianAuth,
  issuer: "auth_service",
  secret_key: env!("GUARDIAN_SECRET", :string)

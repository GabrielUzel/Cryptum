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

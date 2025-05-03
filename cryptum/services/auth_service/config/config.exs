import Config
import Dotenvy

config :auth_service,
  ecto_repos: [AuthService.Repo]

config :auth_service, AuthServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: env!("ENDPOINT_SECRET", :string),
  render_errors: [view: AuthServiceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AuthService.PubSub,
  live_view: [signing_salt: env!("ENDPOINT_SALT", :string)]

config :auth_me, AuthService.GuardianAuth,
  issuer: "auth_me",
  secret_key: env!("GUARDIAN_SECRET", :string)

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"

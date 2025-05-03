import Config

config :auth_service,
  ecto_repos: [AuthService.Repo]

config :auth_service, AuthServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sD9lU5+tu26FLXQ//lYmNnqtc9xt54RdZPQtQbSpfJei4zi7cXZz/pVg16Lrlvqv",
  render_errors: [view: AuthServiceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AuthService.PubSub,
  live_view: [signing_salt: "DAQyg1qe"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"

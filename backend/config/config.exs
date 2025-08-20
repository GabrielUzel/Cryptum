import Config

config :backend,
  ecto_repos: [Backend.Repo],
  generators: [timestamp_type: :utc_datetime]

config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BackendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Backend.PubSub

config :backend, Backend.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :backend, Backend.GuardianAuth,
  issuer: "backend",
  secret_key: System.get_env("GUARDIAN_SECRET")

import_config "#{config_env()}.exs"

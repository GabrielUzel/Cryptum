# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :collaborative_editor, CollaborativeEditorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "W3/nwTgf/SZ0TaR7wpTSVYZEpzZUOqRXVKO0W0NHy+2Ynya6K1LW/SSmKAC+dVHj",
  render_errors: [view: CollaborativeEditorWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: CollaborativeEditor.PubSub,
  live_view: [signing_salt: "52f7lRnW"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

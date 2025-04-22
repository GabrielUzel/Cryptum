# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :files_manager,
  ecto_repos: [FilesManager.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :files_manager, FilesManagerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gQP4N/Qlqa7TIo6uLNxmm6qVM9NULccdywuBNgUBkp/NR6j9HGwYpnLiTo9k75JS",
  render_errors: [view: FilesManagerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FilesManager.PubSub,
  live_view: [signing_salt: "uIgO7JSD"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

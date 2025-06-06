# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :project_manager,
  ecto_repos: [ProjectManager.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :project_manager, ProjectManagerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "j7dTvyTfBN+3muaYpF9xupb80CH7XC/cjmSIJF0orOya7pcItdC3fKlnjyNwyUjU",
  render_errors: [view: ProjectManagerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ProjectManager.PubSub,
  live_view: [signing_salt: "mVXncCe4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

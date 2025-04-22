# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :latex_compiler, LatexCompilerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "B9KBTahHryuN232nhNcak5CHKKnJ2OpUJVL7gIpkTuMbVdwgVlc6FiURgnZJ7X1W",
  render_errors: [view: LatexCompilerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: LatexCompiler.PubSub,
  live_view: [signing_salt: "TtC4KRjN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

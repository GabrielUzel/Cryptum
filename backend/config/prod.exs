import Config

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Backend.Finch
config :swoosh, local: false
config :logger, level: :info
config :backend, :environment, :prod

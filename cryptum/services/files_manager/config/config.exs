import Config

config :files_manager,
  ecto_repos: [FilesManager.Repo],
  generators: [binary_id: true]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"

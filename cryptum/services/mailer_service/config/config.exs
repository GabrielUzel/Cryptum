import Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: MailerService.Finch

import_config "#{Mix.env()}.exs"

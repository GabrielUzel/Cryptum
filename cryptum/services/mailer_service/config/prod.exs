use Mix.Config

config :mailer_service, MailerServiceWeb.Endpoint,
  url: [host: "example.com", port: 80]

config :logger, level: :info

import_config "prod.secret.exs"

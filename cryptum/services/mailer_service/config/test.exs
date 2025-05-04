use Mix.Config

config :mailer_service, MailerServiceWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn

use Mix.Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :mailer_service, MailerServiceWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4001"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

use Mix.Config

config :latex_compiler, LatexCompilerWeb.Endpoint,
  url: [host: "example.com", port: 80]

config :logger, level: :info

import_config "prod.secret.exs"

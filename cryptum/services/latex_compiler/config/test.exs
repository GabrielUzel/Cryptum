use Mix.Config

config :latex_compiler, LatexCompilerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn

import Config

config :latex_compiler, LatexCompilerWeb.Endpoint,
  http: [port: 4003],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

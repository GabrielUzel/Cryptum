import Config

config :tailwind, version: "3.4.17", default: [
  args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/css/app.css
  ),
  cd: Path.expand("../assets", __DIR__)
]

config :esbuild,
  version: "0.7",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --sourcemap=inline),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :auth_service,
  ecto_repos: [AuthService.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"

import Config
import Dotenvy

if Mix.env() in [:dev, :test] do
  env_dir_prefix = System.get_env("RELEASE_ROOT") || Path.expand("./envs/")

  source!([
    Path.absname(".env", env_dir_prefix),
    Path.absname(".#{Mix.env()}.overrides.env", env_dir_prefix)
  ])
end

config :colaborative_editor, ColaborativeEditorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: env!("ENDPOINT_SECRET", :string),
  render_errors: [view: ColaborativeEditorWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ColaborativeEditor.PubSub,
  live_view: [signing_salt: env!("ENDPOINT_SALT", :string)]

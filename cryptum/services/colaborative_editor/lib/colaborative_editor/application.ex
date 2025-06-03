defmodule ColaborativeEditor.Application do
  use Application

  def start(_type, _args) do
    children = [
      ColaborativeEditorWeb.Telemetry,
      {Phoenix.PubSub, name: ColaborativeEditor.PubSub},
      ColaborativeEditorWeb.Endpoint,
      ColaborativeEditor.Document.Supervisor,
      {Registry, keys: :unique, name: ColaborativeEditor.Registry}
    ]

    opts = [strategy: :one_for_one, name: ColaborativeEditor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ColaborativeEditorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

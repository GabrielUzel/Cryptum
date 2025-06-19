defmodule FilesManager.Application do
  use Application

  def start(_type, _args) do
    children = [
      FilesManager.Repo,
      FilesManagerWeb.Telemetry,
      {Phoenix.PubSub, name: FilesManager.PubSub},
      FilesManagerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: FilesManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    FilesManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

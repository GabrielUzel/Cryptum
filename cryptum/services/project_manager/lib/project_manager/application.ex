defmodule ProjectManager.Application do
  use Application

  def start(_type, _args) do
    children = [
      ProjectManager.Repo,
      ProjectManagerWeb.Telemetry,
      {Phoenix.PubSub, name: ProjectManager.PubSub},
      ProjectManagerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ProjectManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ProjectManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule AuthService.Application do
  use Application

  def start(_type, _args) do
    children = [
      AuthService.Repo,
      AuthServiceWeb.Telemetry,
      {Phoenix.PubSub, name: AuthService.PubSub},
      AuthServiceWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AuthService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AuthServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Backend.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BackendWeb.Telemetry,
      Backend.Repo,
      {Phoenix.PubSub, name: Backend.PubSub},
      {Finch, name: Swoosh.Finch},
      BackendWeb.Endpoint,
      {Registry, keys: :unique, name: Backend.Registry},
      Backend.Document.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Backend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

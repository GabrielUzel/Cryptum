defmodule Backend.Application do
  use Application

  @impl true
  def start(_type, _args) do
    base_children = [
      BackendWeb.Telemetry,
      Backend.Repo
    ]

    opts = [strategy: :one_for_one, name: Backend.BaseSupervisor]
    {:ok, _} = Supervisor.start_link(base_children, opts)

    if Application.get_env(:backend, :environment) == :prod do
      case Backend.Release.migrate!() do
        :ok -> :ok
        _ -> exit({:shutdown, :migrate_failed})
      end
    end

    remaining_children = [
      {Phoenix.PubSub, name: Backend.PubSub},
      {Finch, name: Swoosh.Finch},
      BackendWeb.Endpoint,
      {Registry, keys: :unique, name: Backend.Registry},
      Backend.Document.Supervisor
    ]

    Supervisor.start_link(remaining_children,
      strategy: :one_for_one,
      name: Backend.Supervisor
    )
  end

  @impl true
  def config_change(changed, _new, removed) do
    BackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

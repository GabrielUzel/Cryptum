defmodule LatexCompiler.Application do
  use Application

  def start(_type, _args) do
    children = [
      LatexCompilerWeb.Telemetry,
      {Phoenix.PubSub, name: LatexCompiler.PubSub},
      LatexCompilerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: LatexCompiler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LatexCompilerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

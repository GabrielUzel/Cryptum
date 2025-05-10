defmodule MailerService.Application do
  use Application

  def start(_type, _args) do
    children = [
      MailerServiceWeb.Telemetry,
      {Phoenix.PubSub, name: MailerService.PubSub},
      MailerServiceWeb.Endpoint,
      {Finch, name: MailerService.Finch}
    ]

    opts = [strategy: :one_for_one, name: MailerService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    MailerServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

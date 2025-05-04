defmodule MailerServiceWeb.Router do
  use MailerServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MailerServiceWeb do
    pipe_through :api

    post "/confirm/register", EmailController, :confirm_register
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MailerServiceWeb.Telemetry
    end
  end
end

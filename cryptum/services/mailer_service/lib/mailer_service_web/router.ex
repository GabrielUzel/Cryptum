defmodule MailerServiceWeb.Router do
  use MailerServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/auth", MailerServiceWeb do
    pipe_through :api

    post "/confirm/register", EmailController, :confirm_register
  end
end

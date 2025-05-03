defmodule AuthServiceWeb.Router do
  use AuthServiceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", AuthServiceWeb do
    pipe_through :browser

    get "/register", RegisterController, :index
    get "/login", LoginController, :index
  end

  scope "/api/auth", AuthServiceWeb do
    pipe_through :api

    post "/register", RegisterController, :create
    post "/login", LoginController, :authenticate
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AuthServiceWeb.Telemetry
    end
  end
end

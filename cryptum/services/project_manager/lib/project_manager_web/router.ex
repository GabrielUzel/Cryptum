defmodule ProjectManagerWeb.Router do
  use ProjectManagerWeb, :router

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

  scope "/", ProjectManagerWeb do
    pipe_through :browser

    get "/", HomeController, :index
  end

  scope "/api", ProjectManagerWeb do
    pipe_through :api

    # Crud projects
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ProjectManagerWeb.Telemetry
    end
  end
end

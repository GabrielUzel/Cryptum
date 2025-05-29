defmodule ColaborativeEditorWeb.Router do
  use ColaborativeEditorWeb, :router

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

  scope "/editor", ColaborativeEditorWeb do
    pipe_through :browser

    get "/:filename", EditorController, :edit_file
  end

  scope "/api", ColaborativeEditorWeb do
    pipe_through :api
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: ColaborativeEditorWeb.Telemetry
    end
  end
end

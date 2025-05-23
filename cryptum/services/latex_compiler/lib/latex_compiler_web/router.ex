defmodule LatexCompilerWeb.Router do
  use LatexCompilerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LatexCompilerWeb do
    pipe_through :api

    post "/compile", CompilerController, :compile
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: LatexCompilerWeb.Telemetry
    end
  end
end

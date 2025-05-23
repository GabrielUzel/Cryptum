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

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: AuthService.GuardianAuth,
      error_handler: AuthService.GuardianErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/auth", AuthServiceWeb do
    pipe_through :browser

    get "/register", RegisterController, :index
    get "/login", LoginController, :index
    get "/forgotpassword", ForgotPasswordController, :index
    get "/register/confirm", RegisterController, :confirm_email
  end

  scope "/api/auth", AuthServiceWeb do
    pipe_through :api

    post "/register", RegisterController, :create
    post "/login", LoginController, :login
    post "/logout", LoginController, :logout
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AuthServiceWeb.Telemetry
    end
  end
end

defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: Backend.GuardianAuth,
      error_handler: Backend.GuardianErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/api/auth", BackendWeb do
    pipe_through :api

    post "/register", RegisterController, :create
    get "/register/confirm", RegisterController, :confirm_email
    post "/login", LoginController, :login
  end

  scope "/api/auth", BackendWeb do
    pipe_through [:api, :auth]

    post "/logout", LoginController, :logout
    get "/me", LoginController, :me
  end

  scope "/api/editor", BackendWeb do
    pipe_through [:api, :auth]

    get "/:filename", EditorController, :get_file
  end


  if Application.compile_env(:backend, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BackendWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :fetch_session
    plug Guardian.Plug.Pipeline,
      otp_app: :backend,
      module: Backend.GuardianAuth,
      error_handler: Backend.GuardianErrorHandler

    plug BackendWeb.Plugs.CookieToSession, cookie_key: "cryptum_token", session_key: "guardian_default_token"
    plug Guardian.Plug.VerifySession, key: "guardian_default"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api/auth", BackendWeb do
    pipe_through :api

    post "/register", RegisterController, :create
    put "/register/confirm", RegisterController, :confirm_email
    post "/login", LoginController, :login
    post "/email-reset-password", LoginController, :email_reset_password
    put "/reset-password", LoginController, :reset_password
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

  scope "/api/projects", BackendWeb do
    pipe_through [:api, :auth]

    post "/", ProjectController, :create
    get "/", ProjectController, :list_projects
    get "/admin", ProjectController, :list_admin_projects
    get "/member", ProjectController, :list_non_admin_projects
    get "/:id", ProjectController, :get_project
    put "/:id", ProjectController, :update
    delete "/:id", ProjectController, :delete

    post "/add-member", ProjectMemberController, :create
    get "/:project_id/members", ProjectMemberController, :get_project_members
    post "/:project_id/share", ProjectMemberController, :share
    put "/:project_id/members/batch", ProjectMemberController, :manage_members
  end

  scope "/api/files", BackendWeb do
    pipe_through [:api, :auth]

    post "/", FilesController, :create
    post "/upload", FilesController, :upload
    get "/:project_id", FilesController, :list_files
    get "/:project_id/file/:file_id", FilesController, :download
    put "/:project_id/file/:file_id", FilesController, :update
    put "/:project_id/file/:file_id/rename", FilesController, :rename
    delete "/:project_id/file/:file_id", FilesController, :delete
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

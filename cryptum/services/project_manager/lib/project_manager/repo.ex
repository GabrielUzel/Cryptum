defmodule ProjectManager.Repo do
  use Ecto.Repo,
    otp_app: :project_manager,
    adapter: Ecto.Adapters.MyXQL
end

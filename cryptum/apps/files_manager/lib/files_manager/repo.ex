defmodule FilesManager.Repo do
  use Ecto.Repo,
    otp_app: :files_manager,
    adapter: Ecto.Adapters.MyXQL
end

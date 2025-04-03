defmodule Dusk.Repo do
  use Ecto.Repo,
    otp_app: :dusk,
    adapter: Ecto.Adapters.MyXQL
end

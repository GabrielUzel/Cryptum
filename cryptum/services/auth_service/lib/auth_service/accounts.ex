defmodule AuthService.Accounts do
  import Ecto.Query, warn: false
  alias AuthService.Repo

  alias AuthService.Accounts.User

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
  end

  def get_user() do

  end
end

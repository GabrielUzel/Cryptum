defmodule Backend.Accounts do
  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Accounts.User

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(email) do
    Repo.get_by(User, email: email)
  end

  # ! Função sem utilidade no momento
  def change_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
  end

  # ! Função sem utilidade no momento
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def authenticate_user(email, password) do
    case get_user(email) do
      nil ->
        Argon2.no_user_verify()
        {:error, "Email invalid"}
      user ->
        if Argon2.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, "Wrong password"}
        end
    end
  end

  def update_user_email_confirmed(%User{} = user) do
    user
    |> User.changeset(%{"email_confirmed" => true})
    |> Repo.update()
  end
end

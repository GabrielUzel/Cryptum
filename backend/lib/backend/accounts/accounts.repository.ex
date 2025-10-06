defmodule Backend.Accounts do
  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Accounts.User

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_id(id) do
    Repo.get(User, id)
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
    case get_user_by_email(email) do
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

  def email_confirmed_changeset(user) do
    Ecto.Changeset.change(user, email_confirmed: true)
  end

  def update_user_email_confirmed(user) do
    user
    |> email_confirmed_changeset()
    |> Repo.update()
  end
end

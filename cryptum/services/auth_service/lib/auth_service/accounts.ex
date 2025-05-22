defmodule AuthService.Accounts do
  import Ecto.Query, warn: false
  alias AuthService.Repo

  alias AuthService.Accounts.User

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Unused function, but kept for future use
  def change_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
  end

  def get_user(email) do
    Repo.get_by(User, email: email)
  end

  # Unused function, but kept for future use
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def authenticate_user(email, password) do
    case get_user(email) do
      nil ->
        Argon2.no_user_verify()
        {:error, "Email ou senha inválidos"}
      user ->
        if Argon2.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, "Senha incorreta"}
        end
    end
  end
end

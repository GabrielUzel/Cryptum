defmodule AuthService.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password], message: "Há campos vazios")
    |> validate_format(:email, ~r/^[\w._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i, message: "Email inválido")
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/\d/, message: "A senha deve conter ao menos um número")
    |> unique_constraint(:email, message: "Email já cadastrado")
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :hashed_password, Argon2.hash_pwd_salt(pass))
      _ ->
        changeset
    end
  end
end

defmodule Backend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :email_confirmed, :boolean, default: false

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :email_confirmed])
    |> validate_required(:name, message: "Name cannot be empty")
    |> validate_required(:email, message: "Email cannot be empty")
    |> validate_required(:password, message: "Password cannot be empty")
    |> validate_format(:email, ~r/^[\w._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i, message: "Email format invalid")
    |> validate_length(:password, min: 8, message: "Password must be at least 8 characters long")
    |> validate_format(:password, ~r/\d/, message: "Password must contain at least one number")
    |> unique_constraint(:email, message: "Email already registered")
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

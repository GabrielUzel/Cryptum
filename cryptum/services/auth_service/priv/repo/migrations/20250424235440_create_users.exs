defmodule AuthService.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary, size: 16, primary_key: true
      add :name, :string
      add :email, :string
      add :hashed_password, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end

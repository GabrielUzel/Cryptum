defmodule Backend.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :path, :string, null: false
      add :type, :string, null: false
      add :size_bytes, :bigint, null: false

      timestamps()
    end

    create unique_index(:files, [:path])
  end
end

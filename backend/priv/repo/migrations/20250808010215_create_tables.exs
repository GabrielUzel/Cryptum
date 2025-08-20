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

    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create table(:user_projects, primary_key: false) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all), null: false
      add :role, :string, null: false

      timestamps()
    end

    create unique_index(:user_projects, [:user_id, :project_id])
  end
end

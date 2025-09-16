defmodule Backend.Repo.Migrations.CreateTables do
  use Ecto.Migration

def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :email_confirmed, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string, null: false

      timestamps()
    end

    create table(:project_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, :binary_id, null: false
      add :role, :string, null: false

      timestamps()
    end

    create unique_index(:project_members, [:project_id, :user_id], name: :project_members_project_id_user_id_index)
    create unique_index(:project_members, [:project_id, :role], name: :only_one_admin_per_project)

    create table(:files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string, null: false
      add :path, :string, null: false
      add :content_type, :string, null: false
      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:files, [:project_id, :filename])
  end
end

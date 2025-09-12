defmodule Backend.Repo.Migrations.AddProjectsTable do
  use Ecto.Migration

  def change do
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
  end
end

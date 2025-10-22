defmodule Backend.Projects.ProjectMember do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :project_id, :user_id, :role, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @roles ["admin", "member", "guest"]
  schema "project_members" do
    field :project_id, :binary_id
    field :user_id, :binary_id
    field :role, :string

    timestamps()
  end

  def changeset(project_member, attrs) do
    project_member
    |> cast(attrs, [:project_id, :user_id, :role])
    |> validate_required(:project_id, message: "Project ID cannot be empty")
    |> validate_required(:user_id, message: "User ID cannot be empty")
    |> validate_required(:role, message: "Role cannot be empty")
    |> validate_length(:role, max: 50, message: "Role cannot exceed 50 characters")
    |> validate_inclusion(:role, @roles, message: "Role must be admin, member or guest")
    |> unique_constraint([:project_id, :user_id],
      name: :project_members_project_id_user_id_index,
      message: "This user is already a member of the project"
    )
    |> unique_constraint(:project_id,
      name: :only_one_admin_per_project,
      message: "There can only be one admin per project"
    )
  end
end

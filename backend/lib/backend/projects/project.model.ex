defmodule Backend.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :description, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "projects" do
    field :name, :string
    field :description, :string

    has_many :project_members, Backend.Projects.ProjectMember, foreign_key: :project_id
    timestamps()
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description])
    |> validate_required(:name, message: "Name cannot be empty")
    |> validate_required(:description, message: "Description cannot be empty")
    |> validate_length(:name, max: 100, message: "Name cannot exceed 100 characters")
    |> validate_length(:description, max: 500, message: "Description cannot exceed 500 characters")
  end
end

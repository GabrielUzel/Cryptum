defmodule Backend.Files.File do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :filename, :content_type, :path, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "files" do
    field :filename, :string
    field :content_type, :string
    field :path, :string
    field :project_id, :binary_id

    timestamps()
  end

  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :content_type, :path, :project_id])
    |> unique_constraint([:project_id, :filename], message: "File already exists in this project")
    |> validate_format(:content_type, ~r/^[\w\-\+\.]+\/[\w\-\+\.]+$/,
      message: "Invalid content type format"
    )
    |> validate_required([:filename], message: "Filename cannot be empty")
    |> validate_required([:content_type], message: "Content type cannot be empty")
    |> validate_required([:path], message: "Path cannot be empty")
    |> validate_required([:project_id], message: "Project id cannot be empty")
    |> validate_length(:filename, max: 255, message: "Filename cannot exceed 255 characters")
    |> validate_length(:content_type,
      max: 100,
      message: "Content type cannot exceed 100 characters"
    )
    |> validate_length(:path, max: 500, message: "Path cannot exceed 500 characters")
  end
end

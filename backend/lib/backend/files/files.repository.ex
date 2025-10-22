defmodule Backend.FilesRepository do
  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Files.File

  def create_file(project_id, filename, path, content_type) do
    %File{}
    |> File.changeset(%{
      "project_id" => project_id,
      "filename" => filename,
      "path" => path,
      "content_type" => content_type
    })
    |> Repo.insert()
  end

  def list_files_by_project(project_id) do
    File
    |> where([file], file.project_id == ^project_id)
    |> Repo.all()
  end

  def delete_file(file_id) do
    case Repo.get(File, file_id) do
      nil -> {:error, :not_found}
      file -> Repo.delete(file)
    end
  end

  def get_file(file_id) do
    Repo.get(File, file_id)
  end

  def update_file(file_id, attrs) do
    case Repo.get(File, file_id) do
      nil ->
        {:error, :not_found}

      file ->
        file
        |> File.changeset(attrs)
        |> Repo.update()
    end
  end
end

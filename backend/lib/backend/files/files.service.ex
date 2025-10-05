defmodule Backend.Files.FilesService do
  alias Backend.Repo
  alias Backend.FilesRepository
  alias Backend.ProjectsRepository
  alias Azurex.Blob

  def create_file(user_id, project_id, filename, content_type) do
    if !ProjectsRepository.is_at_least_member?(user_id, project_id) do
      {:error, :not_authorized}
    else
      path = "#{project_id}/#{filename}"

      case Blob.put_blob(path, "", content_type) do
        :ok ->
          case FilesRepository.create_file(project_id, filename, path, content_type) do
            {:ok, file} ->
              {:ok, file}

            {:error, changeset} ->
              {:error, changeset}
          end
        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def list_files(user_id, project_id) do
    if !ProjectsRepository.is_at_least_guest?(user_id, project_id) do
      {:error, :not_authorized}
    else
      FilesRepository.list_files_by_project(project_id)
    end
  end

  def download_file(user_id, project_id, file_id) do
    if !ProjectsRepository.is_at_least_guest?(user_id, project_id) do
      {:error, :not_authorized}
    else
      case FilesRepository.get_file(file_id) do
        nil ->
          {:error, :not_found}

        file ->
          case Blob.get_blob(file.path) do
            {:ok, content} ->
              {:ok, %{filename: file.filename, content_type: file.content_type, content: content}}

            {:error, reason} ->
              {:error, reason}
          end
      end
    end
  end

  def update_file(user_id, project_id, file_id, new_content) do
    if !ProjectsRepository.is_at_least_member?(user_id, project_id) do
      {:error, :not_authorized}
    else
      case FilesRepository.get_file(file_id) do
        nil -> {:error, :not_found}

      file ->
        case Blob.put_blob(file.path, new_content, file.content_type) do
          :ok ->
            {:ok, updated_file} =
              file
                |> Ecto.Changeset.change(updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second))
                |> Repo.update()

            {:ok, updated_file}

          {:error, reason} ->
            {:error, reason}
        end
      end
    end
  end

  def rename_file(user_id, project_id, file_id, new_filename) do
    if !ProjectsRepository.is_at_least_member?(user_id, project_id) do
      {:error, :not_authorized}
    else
      case FilesRepository.get_file(file_id) do
        nil -> {:error, :not_found}

        file ->
          new_path = "#{project_id}/#{new_filename}"

          case Blob.copy_blob(file.path, new_path) do
            {:ok, %HTTPoison.Response{status_code: code}} when code in 200..299 ->
              case FilesRepository.update_file(file_id, %{"filename" => new_filename, "path" => new_path}) do
                {:ok, updated_file} ->
                  case Blob.delete_blob(file.path) do
                    :ok -> {:ok, updated_file}
                    {:error, reason} ->
                      Blob.delete_blob(new_path)
                      {:error, {:delete_old_blob_failed, reason}}
                  end

                {:error, changeset} ->
                  Blob.delete_blob(new_path)
                  {:error, changeset}
              end

            {:error, reason} ->
              {:error, {:copy_failed, reason}}
          end
      end
    end
  end

  def delete_file(user_id, project_id, file_id) do
    if !ProjectsRepository.is_at_least_member?(user_id, project_id) do
      {:error, :not_authorized}
    else
      case FilesRepository.get_file(file_id) do
        nil -> {:error, :not_found}
      file ->
        case Blob.delete_blob(file.path) do
          :ok -> FilesRepository.delete_file(file_id)
          {:error, reason} -> {:error, reason}
        end
      end
    end
  end
end

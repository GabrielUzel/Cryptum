defmodule Backend.Files.FilesService do
  alias Backend.Repo
  alias Backend.FilesRepository
  alias Backend.ProjectsRepository
  alias Azurex.Blob

  def create_file(user_id, project_id, filename, content_type) do
    if !ProjectsRepository.is_at_least_member?(user_id, project_id) do
      {:error, :not_authorized}
    else
      encoded_filename = URI.encode(filename)
      path = "#{project_id}/#{encoded_filename}"

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

  def get_document_content(file_id) do
    case FilesRepository.get_file(file_id) do
      nil ->
        {:error, :not_found}

      file ->
        case Blob.get_blob(file.path) do
          {:ok, content} ->
            {:ok, content}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  def upload(user_id, project_id, files) do
    if !ProjectsRepository.is_at_least_member?(user_id, project_id) do
      {:error, :not_authorized}
    else
      files_list = List.wrap(files)

      results =
        Enum.map(files_list, fn file ->
          filename = file.filename
          content_type = file.content_type

          case File.read(file.path) do
            {:ok, content} ->
              upload_single_file(project_id, filename, content_type, content)

            {:error, reason} ->
              {:error, {:read_file_failed, reason}}
          end
        end)

      case Enum.find(results, fn result -> elem(result, 0) == :error end) do
        {:error, reason} ->
          {:error, reason}

        nil ->
          successful_files =
            Enum.map(results, fn {:ok, file} -> file end)

          {:ok, successful_files}
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

  def update_file(file_id, new_content) do
    case FilesRepository.get_file(file_id) do
      nil ->
        {:error, :not_found}

      file ->
        case Blob.put_blob(file.path, new_content, file.content_type) do
          :ok ->
            {:ok, updated_file} =
              file
              |> Ecto.Changeset.change(
                updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
              )
              |> Repo.update()

            {:ok, updated_file}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  def rename_file(user_id, project_id, file_id, new_filename) do
    if !ProjectsRepository.is_at_least_member?(user_id, project_id) do
      {:error, :not_authorized}
    else
      case FilesRepository.get_file(file_id) do
        nil ->
          {:error, :not_found}

        file ->
          new_path = "#{project_id}/#{new_filename}"

          case Blob.copy_blob(file.path, new_path) do
            {:ok, %HTTPoison.Response{status_code: code}} when code in 200..299 ->
              case FilesRepository.update_file(file_id, %{
                     "filename" => new_filename,
                     "path" => new_path
                   }) do
                {:ok, updated_file} ->
                  case Blob.delete_blob(file.path) do
                    :ok ->
                      {:ok, updated_file}

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
        nil ->
          {:error, :not_found}

        file ->
          case Blob.delete_blob(file.path) do
            :ok -> FilesRepository.delete_file(file_id)
            {:error, reason} -> {:error, reason}
          end
      end
    end
  end

  def get_file_project_id(file_id) do
    case FilesRepository.get_file(file_id) do
      nil -> nil
      file -> file.project_id
    end
  end

  defp upload_single_file(project_id, filename, content_type, content) do
    encoded_filename = URI.encode(filename)
    path = "#{project_id}/#{encoded_filename}"

    case Blob.put_blob(path, content, content_type) do
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

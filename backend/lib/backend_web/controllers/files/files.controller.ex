defmodule BackendWeb.FilesController do
  use BackendWeb, :controller
  alias Backend.Files.FilesService

  def create(conn, %{"project_id" => project_id, "filename" => filename, "content_type" => content_type}) do
    user_id = get_current_user_id(conn)

    case FilesService.create_file(user_id, project_id, filename, content_type) do
      {:ok, file} ->
        json(conn, %{message: "File created", file: file})

      {:error, %Ecto.Changeset{} = changeset} ->
        send_resp(conn, 400, Jason.encode!(Backend.TranslateMessages.as_error_array(changeset)))

      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(Backend.TranslateMessages.as_single_error("Failed to create file: #{inspect(reason)}")))
    end
  end

  def upload(conn, %{"project_id" => project_id, "files" => files}) do
    user_id = get_current_user_id(conn)

    case FilesService.upload(user_id, project_id, files) do
      {:ok, _} ->
        json(conn, %{message: "Files uploded"})

      {:error, :not_authorized} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "User does not have sufficient role"})

      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(Backend.TranslateMessages.as_single_error("Failed to upload files: #{inspect(reason)}")))
    end
  end

  def list_files(conn, %{"project_id" => project_id}) do
    user_id = get_current_user_id(conn)

    case FilesService.list_files(user_id, project_id) do
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
      files -> json(conn, files)
    end
  end

  def download(conn, %{"project_id" => project_id, "file_id" => file_id}) do
    user_id = get_current_user_id(conn)

    case FilesService.download_file(user_id, project_id, file_id) do
      {:ok, %{content: content, content_type: content_type, filename: filename}} ->
        conn
        |> put_resp_content_type(content_type)
        |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
        |> send_resp(200, content)

      {:error, :not_authorized} ->
        send_resp(conn, 403, "Not authorized")

      {:error, :not_found} ->
        send_resp(conn, 404, "File not found")

      {:error, reason} ->
        send_resp(conn, 500, "Failed to download file: #{inspect(reason)}")
    end
  end

  def update(conn, %{"project_id" => project_id, "file_id" => file_id, "content" => content}) do
    user_id = get_current_user_id(conn)

    case FilesService.update_file(user_id, project_id, file_id, content) do
      {:ok, file} -> json(conn, file)
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
      {:error, reason} -> send_resp(conn, 400, inspect(reason))
    end
  end

  def rename(conn, %{"project_id" => project_id, "file_id" => file_id, "new_filename" => new_filename}) do
    user_id = get_current_user_id(conn)

    case FilesService.rename_file(user_id, project_id, file_id, new_filename) do
      {:ok, file} -> json(conn, file)
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
      {:error, reason} -> send_resp(conn, 400, inspect(reason))
    end
  end

  def delete(conn, %{"project_id" => project_id, "file_id" => file_id}) do
    user_id = get_current_user_id(conn)

    case FilesService.delete_file(user_id, project_id, file_id) do
      {:ok, _} -> json(conn, %{message: "File deleted successfully"})
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
      {:error, reason} -> send_resp(conn, 400, inspect(reason))
    end
  end

  defp get_current_user_id(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        nil
      user ->
        user.id
    end
  end
end

defmodule BackendWeb.ProjectController do
  use BackendWeb, :controller
  alias Backend.Projects.ProjectsService

  def create(conn, %{"name" => name, "description" => description}) do
    user_id = get_current_user_id(conn)

    case ProjectsService.create_project(user_id, name, description) do
      {:ok, _result} ->
        json(conn, %{message: "Project created"})
      {:error, reason} ->
        send_resp(conn, 400, inspect(reason))
    end
  end

  def list_projects(conn, %{"page" => page, "itemsPerPage" => itemsPerPage}) do
    user_id = get_current_user_id(conn)

    projects = ProjectsService.get_projects(user_id, page, itemsPerPage)
    json(conn, projects)
  end

  def list_admin_projects(conn, _params) do
    user_id = get_current_user_id(conn)

    projects = ProjectsService.get_admin_projects(user_id)
    json(conn, projects)
  end

  def list_non_admin_projects(conn, _params) do
    user_id = get_current_user_id(conn)

    projects = ProjectsService.get_non_admin_projects(user_id)
    json(conn, projects)
  end

  def update(conn, %{"id" => id, "name" => name, "description" => description}) do
    user_id = get_current_user_id(conn)

    case ProjectsService.update_project(user_id, id, name, description) do
      {:ok, _} -> json(conn, %{message: "Project updated successfully"})
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
      {:error, reason} -> send_resp(conn, 400, inspect(reason))
    end
  end

  def delete(conn, %{"id" => id}) do
    user_id = get_current_user_id(conn)

    case ProjectsService.delete_project(user_id, id) do
      {:ok, _} -> json(conn, %{message: "Project deleted successfully"})
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

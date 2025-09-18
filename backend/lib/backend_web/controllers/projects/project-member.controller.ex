defmodule BackendWeb.ProjectMemberController do
  use BackendWeb, :controller
  alias Backend.Projects.ProjectsService

  def get_project_members(conn, %{"project_id" => project_id}) do
    current_user_id = get_current_user_id(conn)

    case ProjectsService.get_project_members(current_user_id, project_id) do
      {:ok, members} -> json(conn, members)
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
    end
  end

  def create(conn, %{"project_id" => project_id, "role" => role}) do
    user_id = get_current_user_id(conn)

    case ProjectsService.add_member_to_project(user_id, project_id, role) do
      {:ok, member} -> json(conn, member)
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
      {:error, reason} -> send_resp(conn, 400, inspect(reason))
    end
  end

  def manage_members(conn, %{"project_id" => project_id, "updates" => updates, "deletes" => deletes}) do
    current_user_id = get_current_user_id(conn)

    case ProjectsService.manage_members(current_user_id, project_id, %{"updates" => updates, "deletes" => deletes}) do
      {:ok, _} -> json(conn, %{message: "Members updated successfully"})
      {:error, :not_authorized} -> send_resp(conn, 403, "Not authorized")
      {:error, :cannot_remove_admin} -> send_resp(conn, 400, "Cannot remove admin")
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

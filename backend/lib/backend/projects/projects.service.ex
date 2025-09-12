defmodule Backend.Projects.ProjectsService do
  alias Backend.ProjectsRepository
  alias Backend.Projects.Project
  alias Backend.Repo

  def create_project(user_id, name, description) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:project, Project.changeset(%Project{}, %{"name" => name, "description" => description}))
    |> Ecto.Multi.run(:admin_member, fn _repo, %{project: project} ->
      ProjectsRepository.create_project_member(project.id, user_id, "admin")
    end)
    |> Repo.transaction()
  end

  def get_projects(user_id, page, itemsPerPage) do
    ProjectsRepository.list_projects(user_id, String.to_integer(page), String.to_integer(itemsPerPage))
  end

  def get_admin_projects(user_id) do
    ProjectsRepository.list_admin_projects(user_id)
  end

  def get_non_admin_projects(user_id) do
    ProjectsRepository.list_non_admin_projects(user_id)
  end

  def update_project(user_id, project_id, name, description) do
    if ProjectsRepository.is_admin?(user_id, project_id) do
      ProjectsRepository.update_project(project_id, name, description)
    else
      {:error, :not_authorized}
    end
  end

  def delete_project(user_id, project_id) do
    if ProjectsRepository.is_admin?(user_id, project_id) do
      ProjectsRepository.delete_project(project_id)
    else
      {:error, :not_authorized}
    end
  end

  def get_project_members(current_user_id, project_id) do
    if ProjectsRepository.is_admin?(current_user_id, project_id) do
      {:ok, ProjectsRepository.list_project_members(project_id)}
    else
      {:error, :not_authorized}
    end
  end

  def add_member_to_project(current_user_id, project_id, user_id, role) do
    if ProjectsRepository.is_admin?(current_user_id, project_id) do
      ProjectsRepository.create_project_member(
        project_id,
        user_id,
        role
      )
    else
      {:error, :not_authorized}
    end
  end

  def update_member_role(current_user_id, project_id, member_id, new_role) do
    if ProjectsRepository.is_admin?(current_user_id, project_id) do
      case ProjectsRepository.get_project_member(member_id) do
        nil -> {:error, :not_found}

        member -> ProjectsRepository.update_project_member(member.id, new_role)
      end
    else
      {:error, :not_authorized}
    end
  end

  def delete_project_member(current_user_id, project_id, member_id) do
    if ProjectsRepository.is_admin?(current_user_id, project_id) do
      case ProjectsRepository.get_project_member(member_id) do
        nil -> {:error, :not_found}

        member ->
          if member.role == "admin" do
            {:error, :cannot_remove_admin}
          else
            ProjectsRepository.delete_project_member(member.id)
          end
      end
    else
      {:error, :not_authorized}
    end
  end
end

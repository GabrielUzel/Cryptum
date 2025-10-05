defmodule Backend.Projects.ProjectsService do
  alias Backend.ProjectsRepository
  alias Backend.FilesRepository
  alias Backend.Projects.Project
  alias Backend.Repo
  alias Azurex.Blob
  alias Ecto.Multi

  def create_project(user_id, name, description) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:project, Project.changeset(%Project{}, %{"name" => name, "description" => description}))
    |> Ecto.Multi.run(:admin_member, fn _repo, %{project: project} ->
      ProjectsRepository.create_project_member(project.id, user_id, "admin")
    end)
    |> Repo.transaction()
  end

  def get_project(user_id, project_id) do
    if ProjectsRepository.is_at_least_guest?(user_id, project_id) do
      ProjectsRepository.get_project(project_id)
    else
      {:error, :not_authorized}
    end
  end

  def get_projects(user_id, page, itemsPerPage) do
    ProjectsRepository.list_projects(user_id, String.to_integer(page), String.to_integer(itemsPerPage))
  end

  def get_admin_projects(user_id, page, itemsPerPage) do
    ProjectsRepository.list_admin_projects(user_id, String.to_integer(page), String.to_integer(itemsPerPage))
  end

  def get_non_admin_projects(user_id, page, itemsPerPage) do
    ProjectsRepository.list_non_admin_projects(user_id, String.to_integer(page), String.to_integer(itemsPerPage))
  end

  def update_project(user_id, project_id, name, description) do
    if String.trim(name) == "" or String.trim(description) == "" do
      {:error, :required_fields}
    else
      if ProjectsRepository.is_admin?(user_id, project_id) do
        ProjectsRepository.update_project(project_id, name, description)
      else
        {:error, :not_authorized}
      end
    end
  end

  def delete_project(user_id, project_id) do
    if ProjectsRepository.is_admin?(user_id, project_id) do
      project = ProjectsRepository.get_project(project_id)

      Multi.new()
      |> Multi.run(:delete_blobs, fn _repo, _changes ->
        files = FilesRepository.list_files_by_project(project_id)

        results =
          Enum.map(files, fn file ->
            Blob.delete_blob(file.path)
          end)

        case Enum.find(results, fn r -> match?({:error, _}, r) end) do
          nil -> {:ok, :all_blobs_deleted}
          {:error, reason} -> {:error, reason}
        end
      end)
      |> Multi.delete(:delete_project, project)
      |> Repo.transaction()
      |> case do
        {:ok, _result} -> {:ok, :project_deleted}
        {:error, _step, reason, _changes} -> {:error, reason}
      end
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

  def add_member_to_project(user_id, project_id, role) do
    ProjectsRepository.create_project_member(
      project_id,
      user_id,
      role
    )
  end

  def manage_members(current_user_id, project_id, %{"updates" => updates, "deletes" => deletes}) do
    if ProjectsRepository.is_admin?(current_user_id, project_id) do
      Repo.transaction(fn ->
        Enum.each(updates, fn %{"member_id" => member_id, "new_role" => new_role} ->
          case ProjectsRepository.get_project_member(member_id) do
            nil -> Repo.rollback({:error, :not_found})
            member -> ProjectsRepository.update_project_member(member.id, new_role)
          end
        end)

        Enum.each(deletes, fn %{"member_id" => member_id} ->
          case ProjectsRepository.get_project_member(member_id) do
            nil -> Repo.rollback({:error, :not_found})
            member ->
              if member.role == "admin" do
                Repo.rollback({:error, :cannot_remove_admin})
              else
                ProjectsRepository.delete_project_member(member.id)
              end
          end
        end)
      end)
    else
      {:error, :not_authorized}
    end
  end
end

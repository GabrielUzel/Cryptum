defmodule Backend.ProjectsRepository do
  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Projects.Project
  alias Backend.Projects.ProjectMember
  alias Backend.Accounts.User

  def create_project(name, description) do
    %Project{}
    |> Project.changeset(%{"name" => name, "description" => description})
    |> Repo.insert()
  end

  def get_project(id) do
    case Repo.get(Project, id) do
      nil -> {:error, :not_found}
      project -> project
    end
  end

  def list_projects(user_id, page, page_size) do
    base_query =
      ProjectMember
      |> where([project_member], project_member.user_id == ^user_id)
      |> join(:inner, [project_member], project in Project, on: project_member.project_id == project.id)
      |> select([project_member, project], project)

    projects =
      base_query
      |> limit(^page_size)
      |> offset(^(page_size * (page - 1)))
      |> Repo.all()

    total_count =
      base_query
      |> exclude(:select)
      |> select([_project_member, _project], count("*"))
      |> Repo.one()

    total_pages =
      if total_count == 0 do
        1
      else
        :math.ceil(total_count / page_size) |> trunc()
      end

    %{projects: projects || [], total_pages: total_pages}
  end

  def list_admin_projects(user_id, page, page_size) do
    base_query =
      ProjectMember
      |> where([pm], pm.user_id == ^user_id and pm.role == "admin")
      |> join(:inner, [project_member], project in Project, on: project_member.project_id == project.id)
      |> select([project_member, project], project)

    projects =
      base_query
      |> limit(^page_size)
      |> offset(^(page_size * (page - 1)))
      |> Repo.all()

    total_count =
      base_query
      |> exclude(:select)
      |> select([_project_member, _project], count("*"))
      |> Repo.one()

    total_pages =
      if total_count == 0 do
        1
      else
        :math.ceil(total_count / page_size) |> trunc()
      end

    %{projects: projects || [], total_pages: total_pages}
  end

  def list_non_admin_projects(user_id, page, page_size) do
    base_query =
      ProjectMember
      |> where([pm], pm.user_id == ^user_id and pm.role in ["member"])
      |> join(:inner, [project_member], project in Project, on: project_member.project_id == project.id)
      |> select([project_member, project], project)

    projects =
      base_query
      |> limit(^page_size)
      |> offset(^(page_size * (page - 1)))
      |> Repo.all()

    total_count =
      base_query
      |> exclude(:select)
      |> select([_project_member, _project], count("*"))
      |> Repo.one()

    total_pages =
      if total_count == 0 do
        1
      else
        :math.ceil(total_count / page_size) |> trunc()
      end

    %{projects: projects || [], total_pages: total_pages}
  end

  def update_project(id, name, description) do
    case Repo.get(Project, id) do
      nil -> {:error, :not_found}

      project ->
        attrs =
          %{}
          |> maybe_put("name", name)
          |> maybe_put("description", description)

        project
        |> Project.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_project(id) do
    case Repo.get(Project, id) do
      nil -> {:error, :not_found}

      project -> Repo.delete(project)
    end
  end

  def list_project_members(project_id) do
    ProjectMember
    |> where([project_member], project_member.project_id == ^project_id)
    |> join(:inner, [project_member], user in User, on: user.id == project_member.user_id)
    |> select([project_member, user], %{
      id: project_member.id,
      name: user.name,
      project_id: project_member.project_id,
      user_id: user.id,
      role: project_member.role,
    })
    |> Repo.all()
  end

  def create_project_member(project_id, user_id, role) do
    %ProjectMember{}
    |> ProjectMember.changeset(%{
      "project_id" => project_id,
      "user_id" => user_id,
      "role" => role
    })
    |> Repo.insert()
  end

  def is_admin?(user_id, project_id) do
    ProjectMember
    |> where([project_member], project_member.project_id == ^project_id and project_member.user_id == ^user_id and project_member.role == "admin")
    |> Repo.exists?()
  end

  def is_at_least_member?(user_id, project_id) do
    ProjectMember
    |> where([project_member], project_member.project_id == ^project_id and project_member.user_id == ^user_id and project_member.role in ["admin", "member"])
    |> Repo.exists?()
  end

  def is_at_least_guest?(user_id, project_id) do
    ProjectMember
    |> where([project_member], project_member.project_id == ^project_id and project_member.user_id == ^user_id and project_member.role in ["admin", "member", "guest"])
    |> Repo.exists?()
  end

  def get_project_member(id), do: Repo.get(ProjectMember, id)

  def update_project_member(memberId, newRole) do
    case Repo.get(ProjectMember, memberId) do
      nil -> {:error, :not_found}

      member ->
        member
        |> ProjectMember.changeset(%{"role" => newRole})
        |> Repo.update()
    end
  end

  def delete_project_member(member_id) do
    case Repo.get(ProjectMember, member_id) do
      nil -> {:error, :not_found}

      member -> Repo.delete(member)
    end
  end

  defp maybe_put(attrs, _key, value) when value in [nil, ""], do: attrs
  defp maybe_put(attrs, key, value), do: Map.put(attrs, key, value)
end

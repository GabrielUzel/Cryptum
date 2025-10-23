import { ProjectMembersGateway } from "@/api/projects/projects-member.gateway";

const projectMembersGateway = new ProjectMembersGateway();

export const getProjectMembers = async (projectId: string) => {
  const data = await projectMembersGateway.getProjectMembers(projectId);
  return data;
};

export const shareProject = async (
  projectId: string,
  email: string,
  role: string,
) => {
  const data = await projectMembersGateway.shareProject(projectId, email, role);
  return data;
};

export const confirmInvitation = async (token: string) => {
  const data = await projectMembersGateway.createProjectMember(token);
  return data;
};

export const manageProjectMembers = async (
  projectId: string,
  updates: { member_id: string; new_role: string }[],
  deletes: { member_id: string }[],
) => {
  const data = await projectMembersGateway.manageProjectMembers(
    projectId,
    updates,
    deletes,
  );
  return data;
};

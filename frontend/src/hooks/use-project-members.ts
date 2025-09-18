import { ProjectMembersGateway } from "@/api/projects/projects-member.gateway";

const projectMembersGateway = new ProjectMembersGateway();

export const getProjectMembers = async (projectId: string) => {
  try {
    const data = await projectMembersGateway.getProjectMembers(projectId);
    return data;
  } catch (error) {
    throw error;
  }
}

export const shareProject = async (projectId: string, email: string, role: string) => {
  try {
    const data = await projectMembersGateway.shareProject(projectId, email, role);
    return data;
  } catch (error) {
    throw error;
  }
}

export const manageProjectMembers = async (projectId: string, updates: { member_id: string; new_role: string; }[], deletes: {member_id: string}[]) => {
  try {
    const data = await projectMembersGateway.manageProjectMembers(projectId, updates, deletes);
    return data;
  } catch (error) {
    throw error;
  }
}
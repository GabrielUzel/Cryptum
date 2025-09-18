import axios, { AxiosInstance } from "axios";

export class ProjectMembersGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000",
      withCredentials: true
    });
  }

  public async getProjectMembers(projectId: string) {
    const response = await this.client.get(`/api/projects/${projectId}/members`);

    return response.data;
  }

  public async shareProject(projectId: string, email: string, role: string) {
    const response = await this.client.post(`/api/projects/${projectId}/share`, {
      email,
      role
    });

    return response.data;
  }

  public async manageProjectMembers(projectId: string, updates: { member_id: string; new_role: string; }[], deletes: {member_id: string}[]) {
    const response = await this.client.put(`/api/projects/${projectId}/members/batch`, {
      updates,
      deletes
    });

    return response.data;
  }
}

export const projectMembersGateway = new ProjectMembersGateway();

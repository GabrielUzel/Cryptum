import axios, { AxiosInstance } from "axios";

export class ProjectMemberGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000",
      withCredentials: true
    });
  }

  public async getProjectMembers(projectId: string) {
    const response = await this.client.get(`/api/${projectId}/members`);

    return response.data;
  }
}

export const userGateway = new ProjectMemberGateway();

import axios, { AxiosInstance } from "axios";

export class ProjectsGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "",
      withCredentials: true,
    });
  }

  public async getProjects(page: number, itemsPerPage: number) {
    const response = await this.client.get(`/api/projects`, {
      params: {
        page,
        itemsPerPage,
      },
    });

    return response.data;
  }

  public async getAdminProjects(page: number, itemsPerPage: number) {
    const response = await this.client.get(`/api/projects/admin`, {
      params: {
        page,
        itemsPerPage,
      },
    });

    return response.data;
  }

  public async getSharedProjects(page: number, itemsPerPage: number) {
    const response = await this.client.get(`/api/projects/member`, {
      params: {
        page,
        itemsPerPage,
      },
    });

    return response.data;
  }

  public async createProject(name: string, description: string) {
    const response = await this.client.post("/api/projects", {
      name,
      description,
    });

    return response.data;
  }

  public async updateProject(
    projectId: string,
    name?: string,
    description?: string,
  ) {
    const response = await this.client.put(`/api/projects/${projectId}`, {
      name,
      description,
    });

    return response.data;
  }

  public async deleteProject(projectId: string) {
    const response = await this.client.delete(`/api/projects/${projectId}`);
    return response.data;
  }

  public async getProjectInfo(projectId: string) {
    const response = await this.client.get(`/api/projects/${projectId}`);
    return response.data;
  }
}

export const projectsGateway = new ProjectsGateway();

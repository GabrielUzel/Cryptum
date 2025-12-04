import axios, { AxiosInstance } from "axios";

export class FilesGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "",
      withCredentials: true,
    });
  }

  public async createFile(projectId: string, filename: string) {
    const response = await this.client.post(`/api/files`, {
      project_id: projectId,
      filename,
      content_type: "text/plain",
    });

    return response.data;
  }

  public async uploadFiles(projectId: string, files: File[]) {
    const formData = new FormData();
    formData.append("project_id", projectId);

    files.forEach((file) => {
      formData.append("files[]", file);
    });

    const response = await this.client.post(`/api/files/upload`, formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });

    return response.data;
  }

  public async getFiles(projectId: string) {
    const response = await this.client.get(`/api/files/${projectId}`);
    return response.data;
  }

  public async downloadFile(projectId: string, fileId: string) {
    const response = await this.client.get(
      `/api/files/${projectId}/file/${fileId}`,
      {
        responseType: "blob",
      },
    );

    return response.data;
  }

  public async downloadFileForCompilation(projectId: string, fileId: string) {
    const response = await this.client.get(
      `/api/files/${projectId}/file/${fileId}`,
      {
        responseType: "blob",
      },
    );

    console.log("download response", response.status, response.headers);
    console.log("blob from backend", response.data, response.data?.size);

    const contentDisposition = response.headers["content-disposition"];
    let filename = "file.tex";

    if (contentDisposition) {
      const match = contentDisposition.match(/filename="(.+)"/);

      if (match) {
        filename = match[1];
      }
    }

    return new File([response.data], filename);
  }

  public async updateFile(projectId: string, fileId: string, content: string) {
    const response = await this.client.put(
      `/api/files/${projectId}/file/${fileId}`,
      {
        content,
      },
    );

    return response.data;
  }

  public async renameFile(
    projectId: string,
    fileId: string,
    newFileName: string,
  ) {
    const response = await this.client.put(
      `/api/files/${projectId}/file/${fileId}/rename`,
      {
        new_filename: newFileName,
      },
    );

    return response.data;
  }

  public async deleteFile(projectId: string, fileId: string) {
    const response = await this.client.delete(
      `/api/files/${projectId}/file/${fileId}`,
    );

    return response.data;
  }
}

export const filesGateway = new FilesGateway();

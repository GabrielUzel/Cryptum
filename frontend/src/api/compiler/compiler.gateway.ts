import axios, { AxiosInstance } from "axios";

export class CompilerGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000",
      withCredentials: true,
    });
  }

  public async compile(file: File) {
    const formData = new FormData();
    formData.append("file", file);

    const response = await this.client.post("/api/compiler/compile", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });

    return response.data;
  }
}

import axios, { AxiosInstance } from "axios";

export class SocketGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000",
      withCredentials: true,
    });
  }

  public async getSocketToken() {
    const response = await this.client.get("/api/auth/socket-token");
    return response.data;
  }
}

export const socketGateway = new SocketGateway();

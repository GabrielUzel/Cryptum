import axios, { AxiosInstance } from "axios";

export class UserGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000",
      withCredentials: true
    });
  }

  public async getUser() {
    const response = await this.client.get(`/api/auth/me`);

    return response.data;
  }

  public async login(email: string, password: string) {
    const response = await this.client.post("/api/auth/login", { 
      email, 
      password 
    });

    return response.data;
  }

  public async logout() {
    const response = await this.client.post("/auth/logout");

    return response.data;
  }

  public async register(name: string, email: string, password: string) {
    const response = await this.client.post("/api/auth/register", {
      name,
      email,
      password
    });

    return response.data;
  }
}

export const userGateway = new UserGateway();

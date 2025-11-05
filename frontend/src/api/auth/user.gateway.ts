import axios, { AxiosInstance } from "axios";

export class UserGateway {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "",
      withCredentials: true,
    });
  }

  public async getUser() {
    const response = await this.client.get(`/api/auth/me`);
    return response.data;
  }

  public async login(email: string, password: string) {
    const response = await this.client.post("/api/auth/login", {
      email,
      password,
    });

    return response.data;
  }

  public async logout() {
    const response = await this.client.post("/api/auth/logout");
    return response.data;
  }

  public async register(name: string, email: string, password: string) {
    const response = await this.client.post("/api/auth/register", {
      name,
      email,
      password,
    });

    return response.data;
  }

  public async confirmRegister(token: string) {
    const response = await this.client.put("/api/auth/register/confirm", {
      token,
    });

    return response.data;
  }

  public async sendEmailResetPassword(email: string) {
    const response = await this.client.post("/api/auth/email-reset-password", {
      email,
    });

    return response.data;
  }

  public async resetPassword(password: string, token: string) {
    const response = await this.client.put("/api/auth/reset-password", {
      password,
      token,
    });

    return response.data;
  }
}

export const userGateway = new UserGateway();

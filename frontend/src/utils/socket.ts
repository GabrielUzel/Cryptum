import { Socket } from "phoenix";
import { getSocketToken } from "@/hooks/use-socket";

export async function createSocket() {
  try {
    const data = await getSocketToken();

    if (!data.token) {
      throw new Error("Token not found");
    }

    const { token } = data;

    const apiUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";
    const socketUrl = apiUrl.replace(/^http/, "ws") + "/socket";

    const socket = new Socket(socketUrl, {
      params: { token },
    });

    socket.connect();
    return socket;
  } catch (error) {
    console.error("Failed to create socket:", error);
    throw error;
  }
}

import { Socket } from "phoenix";
import { getSocketToken } from "@/hooks/use-socket";

export async function createSocket() {
  try {
    const data = await getSocketToken();

    if (!data.token) {
      throw new Error("Token not found");
    }

    const { token } = data;

    const socketUrl = "ws://10.0.24.74:4117/socket";

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

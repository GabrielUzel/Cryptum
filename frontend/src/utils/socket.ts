import { Socket } from "phoenix";
import { getSocketToken } from "@/hooks/use-socket";

export async function createSocket() {
  try {
    const data = await getSocketToken();

    if (!data.token) {
      throw new Error("Token not found");
    }

    const { token } = data;

    const socket = new Socket("ws://localhost:4000/socket", {
      params: { token },
    });

    socket.connect();
    return socket;
  } catch (error) {
    console.error("Failed to create socket:", error);
    throw error;
  }
}

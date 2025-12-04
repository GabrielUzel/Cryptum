import { Socket } from "phoenix";
import { getSocketToken } from "@/hooks/use-socket";

const WS_HOST = process.env.NEXT_PUBLIC_SOCKET_HOST || "localhost";
const WS_PORT = process.env.NEXT_PUBLIC_SOCKET_PORT || "4117";

export async function createSocket() {
  try {
    const data = await getSocketToken();

    if (!data.token) {
      throw new Error("Token not found");
    }

    const { token } = data;

    const socketUrl = `ws://${WS_HOST}:${WS_PORT}/socket`;

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

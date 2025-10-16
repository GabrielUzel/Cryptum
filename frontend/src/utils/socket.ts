import { Socket } from "phoenix";

export function createSocket(token: string | null): Socket {
  const socket = new Socket("ws://localhost:4000/socket", {
    params: { token: token ?? undefined },
  });

  socket.connect();
  return socket;
}

import { Socket } from "phoenix";

export function createSocket(): Socket {
  const socket = new Socket("ws://localhost:4000/socket");

  socket.connect();
  return socket;
}

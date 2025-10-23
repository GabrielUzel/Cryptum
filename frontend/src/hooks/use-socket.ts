import { socketGateway } from "@/api/socket/socket.gateway";

export const getSocketToken = async () => {
  const data = await socketGateway.getSocketToken();
  return data;
};

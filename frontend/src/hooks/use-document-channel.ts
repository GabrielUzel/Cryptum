import { useRef, useState, useCallback } from "react";
import { Socket, Channel } from "phoenix";
import { createSocket } from "@/utils/socket";

type DeltaOp = {
  insert?: string;
  delete?: number;
  retain?: number;
  attributes?: Record<string, unknown>;
};

export default function useDocumentChannel(
  projectId: string,
  setContent: (content: string) => void
) {
  const socketRef = useRef<Socket | null>(null);
  const channelRef = useRef<Channel | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  const connect = useCallback(() => {
    const token = localStorage.getItem("token");
    const socket = createSocket(token);
    socketRef.current = socket;

    const channel = socket.channel(`document:${projectId}`, {});
    channelRef.current = channel;

    channel
      .join()
      .receive("ok", () => {
        console.log("Conectado ao canal do documento:", projectId);
        setIsConnected(true);
      })
      .receive("error", (resp) => {
        console.error("Erro ao conectar ao canal:", resp);
      });

    channel.on("open", (payload: { content: string }) => {
      setContent(payload.content);
    });

    channel.on("update", (payload: { change: { ops: DeltaOp[] } }) => {
      const text = payload.change.ops.map((op: DeltaOp) => op.insert ?? "").join("");
      setContent(text);
    });

    return () => {
      channel.leave();
      socket.disconnect();
      setIsConnected(false);
    };
  }, [projectId, setContent]);

  const sendChange = (newContent: string) => {
    if (channelRef.current && isConnected) {
      const change = {
        ops: [{ insert: newContent }],
      };
      
      channelRef.current.push("update", { change, version: 0 });
    }
  };

  return { connect, sendChange, isConnected };
}
